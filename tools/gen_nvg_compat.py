"""
RONIM NVG compat generator.

Arma draws an NVG's own optic overlay (its modelOptics) above every script UI layer, so RONIM's
swaying tube mask can only sit in front of it if the overlay is removed. A config patch can only
change a class by name, so this tool scans mods for NVG classes that set their own modelOptics and
writes one compat addon per mod PBO that:
  - blanks modelOptics (the engine stops drawing it),
  - stores the original model, its texture and the textured quad's geometry for RONIM
    (azeroot_ronim_modelOptics, azeroot_ronim_maskTexture, azeroot_ronim_opticQuad[]),
so RONIM draws the same texture itself, in front, swaying. Each addon has
skipWhenMissingDependencies = 1 and only loads with its mod. Re-run when NVG mods update.

Usage (from the repository root):
  python tools/gen_nvg_compat.py "<Arma 3>\\@mod1" "<Arma 3>\\@mod2" ...
  python tools/gen_nvg_compat.py --vanilla "<Arma 3>" "<Arma 3>\\@mod1" ...   (also scan base game)
Then: hemtt check -p -Lc14 -e

Needs hemtt on PATH. Extracted files are cached in tools/.cache (git ignored).
"""
import os
import re
import shutil
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(ROOT, "tools", ".cache")
ADDONS = os.path.join(ROOT, "addons")
GENERATED_PREFIX = "compat_nvg_"

# ----------------------------------------------------------------------------- config parsing

TOKEN = re.compile(r'"(?:[^"]|"")*"|[A-Za-z0-9_.\-+]+|[{}\[\];=:,]')


class Cls:
    def __init__(self, name, parent):
        self.name = name
        self.parent = parent
        self.props = {}
        self.classes = {}
        self.external = False


def parse_config(text):
    tokens = TOKEN.findall(text)
    pos = 0

    def value():
        nonlocal pos
        t = tokens[pos]
        if t == "{":
            pos += 1
            items = []
            while tokens[pos] != "}":
                if tokens[pos] == ",":
                    pos += 1
                    continue
                items.append(value())
            pos += 1
            return items
        pos += 1
        if t.startswith('"'):
            return t[1:-1].replace('""', '"')
        try:
            return float(t)
        except ValueError:
            return t

    def body(cls):
        nonlocal pos
        while pos < len(tokens) and tokens[pos] != "}":
            t = tokens[pos]
            if t == "class":
                name = tokens[pos + 1]
                pos += 2
                parent = None
                if tokens[pos] == ":":
                    parent = tokens[pos + 1]
                    pos += 2
                child = Cls(name, parent)
                if tokens[pos] == ";":
                    child.external = True
                    pos += 1
                else:
                    pos += 1  # {
                    body(child)
                    pos += 1  # }
                    if pos < len(tokens) and tokens[pos] == ";":
                        pos += 1
                cls.classes[name.lower()] = child
            elif t == "delete":
                pos += 3
            elif t == ";":
                pos += 1
            else:
                name = t
                pos += 1
                if tokens[pos] == "[":
                    pos += 2
                    name += "[]"
                if tokens[pos] in ("=", "+"):
                    pos += 1
                    if tokens[pos] == "=":
                        pos += 1
                cls.props[name.lower()] = value()
                if pos < len(tokens) and tokens[pos] == ";":
                    pos += 1

    top = Cls("", None)
    body(top)
    return top


# ----------------------------------------------------------------------------- optic model parsing

def parse_optic_model(path):
    """Texture and textured quad of a 2D optic plane (ODOL).

    The plane is a handful of vertices at z = 0: an inner quad carrying the texture and usually
    an outer black frame. The longest run of float triplets with z = 0 is the vertex array; the
    innermost rectangle is the textured quad. Returns (texture, [halfW, halfH, centreX, centreY]).
    """
    data = open(path, "rb").read()
    texture = ""
    for m in re.finditer(rb"\.paa", data):
        start = m.start()
        while start > 0 and 33 <= data[start - 1] < 127 and data[start - 1] not in b"()#,":
            start -= 1
        candidate = data[start:m.end()].decode("ascii", "ignore")
        if "\\" in candidate or "/" in candidate:
            texture = candidate
            break
        if not texture:
            texture = candidate

    best_n, best_o = 0, 0
    for o in range(0, len(data) - 12):
        n = 0
        while o + 12 * (n + 1) <= len(data):
            x, y, z = struct.unpack_from("<fff", data, o + 12 * n)
            if not (abs(x) < 10 and abs(y) < 10 and abs(z) < 1e-4) or abs(x) < 1e-4 or abs(y) < 1e-4:
                break
            n += 1
        if n > best_n:
            best_n, best_o = n, o
    if best_n < 4:
        return texture, None

    verts = [struct.unpack_from("<fff", data, best_o + 12 * i)[:2] for i in range(best_n)]
    inner_x = min(abs(v[0]) for v in verts)
    inner_y = min(abs(v[1]) for v in verts)
    quad = [v for v in verts if abs(v[0]) <= inner_x * 1.25 and abs(v[1]) <= inner_y * 1.25]
    xs = [v[0] for v in quad]
    ys = [v[1] for v in quad]
    geometry = [(max(xs) - min(xs)) / 2, (max(ys) - min(ys)) / 2, (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2]
    return texture, geometry


# ----------------------------------------------------------------------------- PBO handling

def hemtt(*args):
    subprocess.run(["hemtt", *args], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def read_cstr(f):
    out = bytearray()
    while True:
        c = f.read(1)
        if not c or c == b"\x00":
            return out.decode("utf-8", "ignore")
        out += c


def pbo_header(pbo):
    """(prefix, [entry names]) from the uncompressed PBO header."""
    prefix, names = "", []
    with open(pbo, "rb") as f:
        while True:
            name = read_cstr(f)
            fields = struct.unpack("<5I", f.read(20))
            if name == "" and fields[0] == 0x56657273:
                while True:
                    key = read_cstr(f)
                    if key == "":
                        break
                    val = read_cstr(f)
                    if key.lower() == "prefix":
                        prefix = val.strip("\\").lower()
                continue
            if name == "":
                break
            names.append(name)
    return prefix, names


def extract(pbo, name):
    out = os.path.join(CACHE, re.sub(r"[^A-Za-z0-9_.]+", "_", os.path.basename(pbo)[:-4] + "__" + name))
    stamp = out + ".stamp"
    mtime = str(os.path.getmtime(pbo))
    if os.path.exists(out) and os.path.exists(stamp) and open(stamp).read() == mtime:
        return out
    try:
        hemtt("utils", "pbo", "extract", pbo, name, out)
    except subprocess.CalledProcessError:
        print("  skipped (cannot extract):", os.path.basename(pbo), name)
        return None
    open(stamp, "w").write(mtime)
    return out


def find_pbos(folders):
    pbos = []
    for folder in folders:
        for sub in ("addons", "Addons"):
            d = os.path.join(folder, sub)
            if os.path.isdir(d):
                pbos += [os.path.join(d, f) for f in os.listdir(d) if f.lower().endswith(".pbo")]
                break
    return sorted(set(pbos))


# ----------------------------------------------------------------------------- main

def main(argv):
    folders = [a for a in argv if not a.startswith("--")]
    if not folders:
        print(__doc__)
        return 1
    os.makedirs(CACHE, exist_ok=True)

    pbos = find_pbos(folders)
    models = {}         # lower virtual path -> (pbo, entry name)
    configs = []        # (pbo, CfgPatches names, CfgWeapons classes)
    for pbo in pbos:
        try:
            prefix, names = pbo_header(pbo)
        except (OSError, struct.error):
            print("  skipped (bad header):", os.path.basename(pbo))
            continue
        for name in names:
            low = name.replace("/", "\\").lower()
            if low.endswith(".p3d"):
                models[(prefix + "\\" + low) if prefix else low] = (pbo, name)
        for name in names:
            low = name.lower()
            if os.path.basename(low.replace("\\", "/")) != "config.bin":
                continue
            real = extract(pbo, name)
            if real is None:
                continue
            cpp = real + ".cpp"
            if not os.path.exists(cpp) or os.path.getmtime(cpp) < os.path.getmtime(real):
                try:
                    hemtt("utils", "config", "derapify", real, cpp)
                except subprocess.CalledProcessError:
                    print("  skipped (cannot derapify):", os.path.basename(pbo), name)
                    continue
            top = parse_config(open(cpp, encoding="utf-8", errors="ignore").read())
            patches = [c.name for c in top.classes.get("cfgpatches", Cls("", None)).classes.values()]
            weapons = top.classes.get("cfgweapons")
            if weapons and patches:
                configs.append((pbo, patches, weapons))

    # Every CfgWeapons class across all configs, merged by name (later definitions extend)
    merged = {}
    for _pbo, _patches, weapons in configs:
        for key, cls in weapons.classes.items():
            if cls.external:
                merged.setdefault(key, cls)
                continue
            merged[key] = cls

    def is_nvg(key, seen=()):
        cls = merged.get(key)
        if cls is None or key in seen:
            return key == "nvgoggles"
        info = cls.classes.get("iteminfo")
        if info is not None and not info.external and info.props.get("type") == 616:
            return True
        if key == "nvgoggles":
            return True
        return bool(cls.parent) and is_nvg(cls.parent.lower(), seen + (key,))

    by_pbo = {}
    for pbo, patches, weapons in configs:
        for key, cls in weapons.classes.items():
            if cls.external:
                continue
            optic = cls.props.get("modeloptics")
            if not isinstance(optic, str) or optic == "" or not is_nvg(key):
                continue
            model = optic.strip("\\").lower()
            if not model.endswith(".p3d"):
                model += ".p3d"
            texture, geometry = ("", None)
            if model in models:
                real = extract(*models[model])
                if real:
                    texture, geometry = parse_optic_model(real)
            entry = by_pbo.setdefault(pbo, {"patches": set(), "classes": {}})
            entry["patches"].update(patches)
            entry["classes"][key] = (cls, optic, texture, geometry)

    # Rewrite generated addons
    for name in os.listdir(ADDONS):
        if name.startswith(GENERATED_PREFIX):
            shutil.rmtree(os.path.join(ADDONS, name))

    total = 0
    for pbo, entry in sorted(by_pbo.items()):
        slug = re.sub(r"[^a-z0-9]+", "_", os.path.basename(pbo)[:-4].lower()).strip("_")
        addon = GENERATED_PREFIX + slug
        write_addon(addon, pbo, sorted(entry["patches"]), entry["classes"], merged)
        total += len(entry["classes"])
        print(f"{addon}: {len(entry['classes'])} NVGs")
    print(total, "NVG classes patched in", len(by_pbo), "addons")
    return 0


def fmt(v):
    return f"{v:.6f}".rstrip("0").rstrip(".") if v else "0"


def write_addon(addon, pbo, patches, classes, merged):
    d = os.path.join(ADDONS, addon)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "$PBOPREFIX$"), "w", encoding="utf-8", newline="") as f:
        f.write(f"z\\azeroot_ronim\\addons\\{addon}")
    with open(os.path.join(d, "script_component.hpp"), "w", encoding="utf-8", newline="\n") as f:
        f.write(f'#define COMPONENT {addon}\n#include "\\z\\azeroot_ronim\\addons\\main\\script_mod.hpp"\n\n'
                '#include "\\z\\azeroot_ronim\\addons\\main\\script_macros.hpp"\n')

    # Parents first: a patched class whose parent is patched too comes after it
    ordered, done = [], set()

    def visit(key):
        if key in done or key not in classes:
            return
        parent = (classes[key][0].parent or "").lower()
        visit(parent)
        done.add(key)
        ordered.append(key)

    for key in sorted(classes):
        visit(key)

    externals = sorted({classes[k][0].parent for k in ordered if classes[k][0].parent and classes[k][0].parent.lower() not in classes},
                       key=str.lower)
    out = [
        f"// Generated by tools/gen_nvg_compat.py from {os.path.basename(pbo)} - re-run the tool, do not edit.",
        '#include "script_component.hpp"',
        "",
        "class CfgPatches {",
        "    class ADDON {",
        f'        name = "RONIM - NVG overlay compat ({os.path.basename(pbo)[:-4]})";',
        "        units[] = {};",
        "        weapons[] = {};",
        "        requiredVersion = REQUIRED_VERSION;",
        "        requiredAddons[] = {" + ", ".join(f'"{p}"' for p in ["azeroot_ronim_main", *patches]) + "};",
        "        skipWhenMissingDependencies = 1;",
        '        author = "Root, Azer0";',
        '        authors[] = {"Root", "Azer0"};',
        '        url = "https://github.com/A3-Root/Azer0ot_RONIM";',
        "        VERSION_CONFIG;",
        "    };",
        "};",
        "",
        "// modelOptics blanked so the engine no longer draws the overlay; RONIM draws the same texture itself",
        "class CfgWeapons {",
    ]
    out += [f"    class {p};" for p in externals]
    for key in ordered:
        cls, optic, texture, geometry = classes[key]
        header = f"    class {cls.name}: {cls.parent} {{" if cls.parent else f"    class {cls.name} {{"
        out.append(header)
        out.append('        modelOptics = "";')
        out.append(f'        azeroot_ronim_modelOptics = "{optic}";')
        if texture:
            tex = texture if texture.startswith("\\") else "\\" + texture
            out.append(f'        azeroot_ronim_maskTexture = "{tex}";')
        if geometry:
            out.append("        azeroot_ronim_opticQuad[] = {" + ", ".join(fmt(v) for v in geometry) + "};")
        out.append("    };")
    out.append("};")
    with open(os.path.join(d, "config.cpp"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out) + "\n")


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
