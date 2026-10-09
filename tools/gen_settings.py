"""
RONIM settings generator.

One table below is the single source for:
  addons/main/initSettings.inc.sqf          (CBA settings + control metadata for the Zeus dialogs)
  addons/main/stringtable.xml               (setting titles/tooltips + every UI string in EXTRA)
  addons/modules/settingsAttributes.inc.hpp (3DEN "RONIM Settings" module attributes)
  docs/SETTINGS.md                          (reference tables)

Run from the repository root:  python tools/gen_settings.py
Then: hemtt check -p -Lc14 -e

Tooltip conventions: line 1 says what it does, line 2 says what higher/lower or each state does.
CBA shows the default on the reset button, so tooltips do not repeat it.
"""
import html
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NL = "\\n"  # literal \n: line break in Arma tooltips

CATS = []  # [(key, title, [settings])]


def cat(key, title):
    CATS.append((key, f"{len(CATS) + 1:02d} {title}", []))


def _add(entry):
    CATS[-1][2].append(entry)


def check(name, title, tip, default, glob=True):
    _add(dict(name=name, kind="CHECKBOX", title=title, tip=tip, default=default, glob=glob))


def slider(name, title, tip, lo, hi, default, dec=0, pct=False, glob=True):
    _add(dict(name=name, kind="SLIDER", title=title, tip=tip, lo=lo, hi=hi, default=default, dec=dec, pct=pct, glob=glob))


def edit(name, title, tip, default="", glob=True):
    _add(dict(name=name, kind="EDITBOX", title=title, tip=tip, default=default, glob=glob))


def lst(name, title, tip, values, options, default_index, glob=True):
    _add(dict(name=name, kind="LIST", title=title, tip=tip, values=values, options=options, default=default_index, glob=glob))


def tip(*lines):
    return NL.join(lines)


MAG = "Only while aiming through a magnified optic (above the General magnification threshold) with NVGs on."
LISTFMT = "Comma separated classnames, case insensitive."

# ======================================================================= 01 General
cat("general", "General")
check("enabled", "Enable RONIM", tip(
    "Master switch for every RONIM effect.",
    "Off = vanilla night vision."), True)
check("allowVehicles", "Apply in FFV seats", tip(
    "Also apply RONIM to players who can use their weapon from a vehicle seat (FFV, turned out).",
    "Off = only on foot."), True)
slider("magThreshold", "Magnification threshold", tip(
    "Zoom at or above which an optic counts as magnified. Optic features (mount failure, bruise, ADS sway,",
    "misalignment, flash bloom, monocular reticle) need this. Iron sights and holo sights sit around 1.0-1.3x."), 1.0, 8.0, 1.5, 2)
check("autoDetectIntegrated", "Auto-detect integrated NV optics", tip(
    "Optics whose own vision modes include NVG or thermal never get the optic features.",
    "Off = only the Classes > Integrated NV optics list counts."), True)

# ======================================================================= 02 Night vision picture
cat("pip", "Night Vision Picture (PiP)")
check("pipEnabled", "PiP night vision", tip(
    "In first person, RONIM renders the night vision itself in a picture-in-picture view inside the tubes and keeps",
    "the game's own NVG mode off (no vanilla/ACE tube overlay). A monocular leaves the other eye with the real view.",
    "Needs PiP enabled in video options. Third person and disabled PiP fall back to the game's NVG mode.",
    "Off = the game's NVG mode with RONIM's tube overlay drawn in front of it."), False)
lst("pipResolution", "PiP resolution", tip(
    "Render resolution of the night vision picture.",
    "Higher = sharper, costs more FPS."), [512, 1024, 2048], [("512", ""), ("1024", ""), ("2048", "")], 1, glob=False)
slider("pipForwardHip", "Camera offset (hip)", tip(
    "Metres the night vision camera sits ahead of your eye when not aiming, so it does not see the inside of the",
    "goggles or helmet."), 0.0, 0.6, 0.22, 2)
slider("pipForwardAds", "Camera offset (aiming)", tip(
    "Metres the night vision camera sits ahead of the optic while aiming, past the scope body."), 0.0, 1.5, 0.5, 2)
slider("pipFovScale", "PiP field of view", tip(
    "Fine-tunes the night vision picture's field of view against the real view.",
    "Above 1 = wider, below 1 = narrower."), 0.8, 1.25, 1.0, 3, glob=False)

# ======================================================================= 03 Tube mask and sway
cat("mask", "Tube Mask and Sway")
check("maskEnabled", "Draw NVG tube mask", tip(
    "Black out everything outside the NVG tube(s) while NVGs are on.",
    "Off = full screen night vision."), True)
lst("maskSource", "Tube shape source", tip(
    "Where the tube mask's shape comes from.",
    "Auto: the NVG's own optic overlay texture (from RONIM's NVG compat addons or found next to its modelOptics),",
    "else its ACE border texture, else RONIM's.",
    "Size and position per NVG come from Classes > Mask calibration and the calibration keybinds."),
    [0, 1, 2, 3], [("Auto", ""), ("NVG optic texture", ""), ("ACE border texture", ""), ("RONIM generic", "")], 0)
check("monoCustomMask", "Custom monocular mask", tip(
    "Monocular NVGs always use RONIM's monocular mask: one tube in front of the chosen eye, the rest dark,",
    "whatever the NVG's own overlay looks like."), True)
slider("opticModelScale", "Optic overlay scale", tip(
    "Screen heights per optic model unit, used to size NVG overlays from their real model geometry (NVG compat addons).",
    "Calibrate one NVG, then every NVG overlay is sized correctly relative to it. The calibration hint shows the value."),
    2, 60, 19.41, 2)
check("maskOverHud", "Mask in front", tip(
    "Draw the tube overlay over the HUD layer, in front of the NVG's own optic overlay.",
    "Covers HUD elements in the blacked out area while NVGs are on. Off = under the HUD."), True, glob=False)
slider("maskOpacity", "Mask opacity", tip(
    "How dark the area outside the tubes is.",
    "Lower = you can see a little around the tubes."), 0.5, 1.0, 1.0, 2, pct=True, glob=False)
slider("maskScale", "Tube size", tip(
    "Size of the tube view.",
    "Higher = larger tubes, less blacked out."), 0.6, 1.6, 1.0, 2, glob=False)
lst("monoSide", "Monocular eye", tip(
    "Which eye a monocular NVG sits in front of."),
    [0, 1], [("Left eye", ""), ("Right eye", "")], 1)
lst("monoOtherEye", "Monocular other eye", tip(
    "What the eye without the tube sees.",
    "Real view needs PiP night vision; in the game's NVG mode the other eye is always dark."),
    [0, 1], [("Dark", ""), ("Real view (PiP)", "")], 1)
slider("monoShift", "Monocular tube shift", tip(
    "How far a monocular tube sits off centre, as a fraction of screen width.",
    "0 = centred."), 0.0, 0.4, 0.25, 2)
check("swayEnabled", "Tube sway", tip(
    "The tube view lags and bobs with head movement, walking and fatigue.",
    "Off = tube fixed to the screen centre."), True)
slider("swayStrength", "Sway strength", tip(
    "Overall multiplier for all tube sway.",
    "2.0 = twice the movement, 0.5 = half."), 0.0, 6.0, 1.6, 2)
slider("swayLook", "Head turn lag", tip(
    "How much the tube lags behind when you turn your head."), 0.0, 5.0, 1.5, 2)
slider("swayMove", "Walking bob", tip(
    "How much the tube bobs while moving. Scales with speed, less when crouched or prone."), 0.0, 5.0, 1.5, 2)
slider("swayIdle", "Idle drift", tip(
    "Slow drift while standing still."), 0.0, 5.0, 1.3, 2)
slider("swayFatigue", "Fatigue effect", tip(
    "Extra drift when tired.",
    "0 = fatigue has no effect."), 0.0, 5.0, 1.0, 2)
slider("swayStiffness", "Mount stiffness", tip(
    "How firmly the mount pulls the tube back to centre.",
    "Higher = snappier, smaller swings. Lower = looser, wobblier."), 3, 60, 16, 0)
slider("swayDamping", "Mount damping", tip(
    "How quickly wobbles die out.",
    "Higher = settles fast. Lower = keeps bouncing."), 1, 20, 7, 1)
slider("swayMaxOffset", "Max sway offset", tip(
    "Furthest the tube may sway from centre, as a fraction of screen height."), 0.01, 0.4, 0.12, 3)
lst("aceMaskMode", "ACE NVG mask handling", tip(
    "Only with ACE Nightvision loaded and the game's NVG mode in use (PiP off / third person).",
    "RONIM mask hides the ACE mask; ACE mask keeps ACE's and turns RONIM's off (no tube sway); Both draws both."),
    [0, 1, 2], [("RONIM mask", ""), ("ACE mask", ""), ("Both", "")], 0)

# ======================================================================= 03 ADS sway and misalignment
cat("ads", "ADS Sway and Misalignment")
check("adsSwayEnabled", "Independent ADS sway", tip(
    "While aiming through a magnified optic with NVGs on, the tube sways on its own, out of step with the",
    "weapon, and recoil kicks it. " + MAG), True)
slider("adsSwayStrength", "ADS sway strength", tip(
    "Size of the independent tube sway while aiming.",
    "2.0 = twice the movement, 0 = none."), 0.0, 8.0, 3.0, 2)
slider("recoilKick", "Recoil kick", tip(
    "How hard each shot knocks the tube. Scales with the round's power."), 0.0, 8.0, 2.0, 2)
slider("recoilCamShake", "Recoil camera shake", tip(
    "Extra camera shake per shot while aiming with NVGs.",
    "0 = off."), 0.0, 5.0, 0.0, 1)
slider("adsAimMult", "Weapon sway multiplier", tip(
    "Weapon sway multiplier while aiming through a magnified optic with NVGs on (uses ACE sway factors with ACE).",
    "1.0 = no change, 1.5 = 50% more sway."), 1.0, 3.0, 1.0, 2)
check("misalignEnabled", "Mount misalignment", tip(
    "Shots can shift the NVG mount so the tube sits off centre until it recovers or is re-seated. " + MAG), True)
slider("misalignChance", "Misalignment chance per shot", tip(
    "Chance that one shot shifts the mount. Scales with the round's power."), 0.0, 1.0, 0.05, 1, pct=True)
slider("misalignStep", "Misalignment per shift", tip(
    "How far one shift moves the tube, as a fraction of screen height."), 0.002, 0.08, 0.015, 3)
slider("misalignMax", "Max misalignment", tip(
    "Furthest the mount can end up off centre, as a fraction of screen height."), 0.01, 0.3, 0.08, 3)
check("misalignToggleReset", "NVG toggle re-seats", tip(
    "Turning the NVGs off and on again clears the misalignment."), True)
check("misalignAutoRecover", "Auto recover", tip(
    "The mount settles back by itself after you stop shooting."), True)
slider("misalignRecoverDelay", "Auto recover delay", tip(
    "Seconds without firing before the mount starts settling back."), 0, 30, 2, 1)
slider("misalignRecoverTime", "Auto recover time", tip(
    "Seconds the mount takes to settle fully back once it starts."), 1, 30, 5.5, 1)
check("reseatAction", "ACE re-seat action", tip(
    "Only with ACE: self-interaction > Equipment > Re-seat NVG mount, shown while misaligned."), True)
slider("reseatTime", "Re-seat time", tip(
    "Seconds the ACE re-seat action takes."), 1, 20, 5.5, 1)

# ======================================================================= 04 Mount failure
cat("mount", "Mount Failure")
check("mountEnabled", "Mount failure", tip(
    "Shots can break the NVG mount so the goggles fall to the ground. " + MAG), True)
slider("mountChance", "Failure chance per shot", tip(
    "Chance that one shot breaks the mount."), 0.0, 0.2, 0.002, 1, pct=True)
check("mountRecoilScale", "Scale with recoil", tip(
    "Powerful rounds (7.62, .338, .50) break mounts more often than 5.56 or pistol rounds."), True)
check("mountNotify", "Notify player", tip(
    "Show a hint when your NVGs fall off."), True)

# ======================================================================= 05 Recoil bruise
cat("bruise", "Recoil Bruise")
check("bruiseEnabled", "Recoil bruising", tip(
    "Shots can knock the NVG into your face and bruise your head (ACE medical: contusion). " + MAG), True)
slider("bruiseChance", "Bruise chance per shot", tip(
    "Chance that one shot bruises you (outside the cooldown)."), 0.0, 1.0, 0.1, 0, pct=True)
slider("bruiseDamage", "Bruise damage", tip(
    "Damage of one bruise. ACE needs at least 0.1 for a wound; below 0.35 it is a contusion or crush."), 0.1, 0.34, 0.15, 2)
slider("bruiseCooldown", "Bruise cooldown", tip(
    "Minimum seconds between two bruises."), 0, 120, 15, 0)
check("bruiseRecoilScale", "Scale with recoil", tip(
    "Powerful rounds bruise more often and harder."), True)

# ======================================================================= 06 Muzzle flash bloom
cat("flash", "Muzzle Flash Bloom")
check("flashEnabled", "Muzzle flash bloom", tip(
    "Firing without a suppressor washes the NVG image out white for a moment."), True)
check("flashRequireMagnified", "Only through magnified optics", tip(
    "Bloom only while aiming through a magnified optic.",
    "Off = any shot with NVGs on."), True)
slider("suppressorAudible", "Suppressor detection", tip(
    "Muzzle attachments that cut sound below this value count as suppressors. Flash hiders and brakes do not.",
    "Classes > suppressor lists override this."), 0.05, 1.0, 0.6, 2)
slider("flashIntensity", "Bloom intensity", tip(
    "How white the image gets on a shot."), 0.0, 1.0, 0.9, 0, pct=True)
slider("flashDuration", "Bloom duration", tip(
    "Seconds the bloom takes to fade."), 0.1, 3.0, 1.0, 2)
slider("flashStack", "Follow-up shot bloom", tip(
    "Share of full bloom that a shot adds while the previous bloom is still fading (automatic fire)."), 0.0, 1.0, 0.35, 0, pct=True)
check("flashNearby", "Nearby shooters", tip(
    "Unsuppressed shots from other units close to you and in view also bloom your NVGs."), False)
slider("flashNearbyRange", "Nearby range", tip(
    "Distance in metres within which other shooters cause bloom. Fades with distance."), 2, 50, 15, 0)
slider("flashNearbyScale", "Nearby intensity", tip(
    "Bloom from another shooter at point blank, relative to your own shot."), 0.0, 1.0, 0.6, 0, pct=True)

# ======================================================================= 07 Monocular reticle
cat("reticle", "Reticle")
check("reticleEnabled", "Reticle over night vision", tip(
    "PiP: the night vision picture covers the scope, so a copy of the optic's reticle is drawn at the aim point on",
    "top of it. Tube sway and misalignment move the picture against it. " + MAG), True)
check("reticleSideCopy", "Monocular side copy", tip(
    "Game NVG mode only (PiP off / third person): with a monocular, draw a copy of the reticle on the side",
    "without the tube."), True)
lst("reticleStyle", "Default reticle", tip(
    "Reticle drawn when the optic has no entry in Classes > Reticle per optic."),
    [0, 1, 2, 3], [("Dot", ""), ("Cross", ""), ("Chevron", ""), ("Mil-dot", "")], 1)
slider("reticleOffset", "Reticle offset", tip(
    "Monocular side copy: horizontal distance from screen centre, as a fraction of screen width."), 0.05, 0.45, 0.22, 2)
slider("reticleSize", "Reticle size", tip(
    "Reticle size as a fraction of screen height."), 0.02, 0.4, 0.14, 2, glob=False)
slider("reticleOpacity", "Reticle opacity", tip(
    "How visible the reticle copy is."), 0.1, 1.0, 0.8, 0, pct=True, glob=False)
lst("reticleColor", "Reticle colour", tip("Colour of the reticle copy."),
    [0, 1, 2, 3], [("Red", ""), ("Green", ""), ("Amber", ""), ("Black", "")], 0, glob=False)

# ======================================================================= 08 Classes
cat("classes", "Classes")
edit("integratedWhitelist", "Integrated NV optics", tip(
    "Optics (or weapons with built-in optics) treated as having their own night vision: no optic features.", LISTFMT))
edit("integratedBlacklist", "Never integrated", tip(
    "Optics never treated as integrated NV, even if auto-detection says so.", LISTFMT))
edit("nvgMono", "Monocular NVGs", tip("NVG classes forced to one tube.", LISTFMT))
edit("nvgBino", "Binocular NVGs", tip("NVG classes forced to two tubes.", LISTFMT))
edit("nvgQuad", "Panoramic (quad) NVGs", tip("NVG classes forced to four tubes.", LISTFMT))
edit("nvgIgnore", "Ignored NVGs", tip(
    "NVG / HMD classes RONIM leaves alone entirely (no mask, no features).", LISTFMT))
edit("nvgImmune", "Unbreakable mounts", tip(
    "NVG classes that never fall off (mount failure).", LISTFMT))
edit("suppressorWhitelist", "Always suppressor", tip(
    "Muzzle attachments always counted as suppressors (no bloom).", LISTFMT))
edit("suppressorBlacklist", "Never suppressor", tip(
    "Muzzle attachments never counted as suppressors (bloom).", LISTFMT))
edit("maskCalibration", "Mask calibration", tip(
    "Tube mask size and position per NVG as class:scale:offsetX:offsetY:stretch entries, comma separated.",
    "Scale = mask height in screen heights, offsets in screen fractions, stretch = width multiplier.",
    "Tune in game with the RONIM calibration keybinds (saved per player); the hint shows the entry to paste here."))
edit("reticleMap", "Reticle per optic", tip(
    "Monocular reticle per optic as class:style pairs, styles dot, cross, chevron, mildot.",
    "Example: optic_Hamr:chevron, optic_Arco:chevron, optic_MRCO:dot"))

# ======================================================================= 09 Debug
cat("debug", "Debug")
check("debugLog", "RPT logging", tip("Write RONIM events (mount failures, bruises, overrides) to the RPT log."), False)
check("debugOverlay", "Debug overlay", tip("Show RONIM's current state on screen (local player)."), False, glob=False)


# ======================================================================= extra UI strings
EXTRA = {
    "cat": "RONIM - Optic Nightvision",
    "keep": "Keep setting",
    "off": "Off",
    "on": "On",
    "mountBrokenHint": "Your NVG mount broke - the goggles fell off.",
    "reseat": "Re-seat NVG mount",
    "reseating": "Re-seating NVG mount...",
    "reseated": "NVG mount re-seated.",
    "kb_category": "RONIM",
    "kb_scaleUp": "Mask calibration: bigger",
    "kb_scaleDown": "Mask calibration: smaller",
    "kb_up": "Mask calibration: up",
    "kb_down": "Mask calibration: down",
    "kb_left": "Mask calibration: left",
    "kb_right": "Mask calibration: right",
    "kb_wider": "Mask calibration: wider",
    "kb_narrower": "Mask calibration: narrower",
    "kb_reset": "Mask calibration: reset this NVG",
    "calibHint": "RONIM mask calibration (saved for you)",
    # modules
    "category": "RONIM",
    "eden_settings": "RONIM Settings",
    "eden_settings_desc": "Mission-wide overrides of RONIM's CBA settings. Keep setting leaves a value alone.",
    "eden_exempt": "RONIM Exempt Units",
    "eden_exempt_desc": "Synced units (or all units of synced groups) are exempt from every RONIM effect.",
    "eden_exempt_value": "Exempt",
    "eden_exempt_value_desc": "On = exempt, Off = remove an exemption.",
    "attr_exempt": "RONIM: exempt",
    "attr_exempt_desc": "This unit gets no RONIM night vision effects.",
    "zeus_settings": "RONIM Settings",
    "zeus_exempt": "Toggle Exempt",
    "zeus_breakMount": "Break NVG Mount",
    "zeus_reseat": "Re-seat NVG Mount",
    "zeus_optics": "Integrated NV Optics",
    "zeus_features": "Toggle Features",
    "pickCategory": "Settings group",
    "clearOverrides": "Clear these overrides",
    "clearOverrides_desc": "Return every setting in this group to its CBA value instead of applying.",
    "msgApplied": "RONIM overrides applied",
    "msgCleared": "RONIM overrides cleared",
    "msgNeedUnit": "Place the module on a unit",
    "msgNoNvg": "Unit has no NVGs",
    "msgExemptOn": "Unit exempt from RONIM",
    "msgExemptOff": "Unit no longer exempt",
    "msgBroken": "NVG mount broken",
    "msgReseated": "NVG mount re-seated",
    "msgOptics": "Integrated NV optics updated",
    "msgFeatures": "RONIM features updated",
    "opticsAdd": "Add classes",
    "opticsAdd_desc": "Comma separated optic classes to treat as integrated NV.",
    "opticsRemove": "Remove classes",
    "opticsRemove_desc": "Comma separated optic classes to remove again.",
    "opticsCurrent": "Use the unit's current optic",
    "opticsCurrent_desc": "Module placed on a unit: add the optic on its current weapon.",
    "featuresTitle": "RONIM features (Keep = CBA setting)",
}

FEATURES = [
    ("enabled", "RONIM (all)"),
    ("pipEnabled", "PiP night vision"),
    ("maskEnabled", "Tube mask"),
    ("swayEnabled", "Tube sway"),
    ("adsSwayEnabled", "ADS sway"),
    ("misalignEnabled", "Misalignment"),
    ("mountEnabled", "Mount failure"),
    ("bruiseEnabled", "Recoil bruise"),
    ("flashEnabled", "Flash bloom"),
    ("reticleEnabled", "Reticle"),
]


# ======================================================================= output


def sqf_str(s):
    return '"' + s.replace('"', '""') + '"'


def num(v):
    if isinstance(v, float) and v.is_integer():
        v = int(v)
    return str(v)


def valueinfo(e):
    k = e["kind"]
    if k == "CHECKBOX":
        return "true" if e["default"] else "false"
    if k == "EDITBOX":
        return sqf_str(e["default"])
    if k == "SLIDER":
        args = [num(e["lo"]), num(e["hi"]), num(e["default"]), str(e["dec"])]
        if e["pct"]:
            args.append("true")
        return "[" + ", ".join(args) + "]"
    if k == "LIST":
        values = ", ".join(str(v) for v in e["values"])
        labels = ", ".join(f"[LSTRING({e['name']}_opt{i})]" for i in range(len(e["options"])))
        return f"[[{values}], [{labels}], {e['default']}]"
    raise ValueError(k)


def build_sqf():
    out = [
        "// CBA settings, generated by tools/gen_settings.py - edit the table there, not this file.",
        "// Every value is read live (MSET), so changes in Addon Options apply mid-mission.",
        "// Modules/API may layer runtime overrides on top (azeroot_ronim_fnc_setOverride).",
        "#define CAT LSTRING(cat)",
    ]
    for key, _title, _settings in CATS:
        out.append(f"#define SUB_{key.upper()} [CAT, LSTRING(cat_{key})]")
    for key, title, settings in CATS:
        out.append("")
        out.append(f"// ---------------------------------------------------------------- {title}")
        for e in settings:
            glob = "true" if e["glob"] else "false"
            out.append(f"[QGVAR({e['name']}), \"{e['kind']}\", [LSTRING({e['name']}), LSTRING({e['name']}_desc)], SUB_{key.upper()}, {valueinfo(e)}, {glob}] call CBA_fnc_addSetting;")

    out.append("")
    out.append("// Control data per setting for the Zeus settings dialog: [type, ...]")
    out.append("// SLIDER: min, max, decimals, percent. LIST: values, label keys.")
    meta = []
    for _key, _title, settings in CATS:
        for e in settings:
            k = e["kind"]
            if k == "SLIDER":
                m = f'["SLIDER", {num(e["lo"])}, {num(e["hi"])}, {e["dec"]}, {"true" if e["pct"] else "false"}]'
            elif k == "LIST":
                values = ", ".join(str(v) for v in e["values"])
                labels = ", ".join(f"LSTRING({e['name']}_opt{i})" for i in range(len(e["options"])))
                m = f'["LIST", [{values}], [{labels}]]'
            else:
                m = f'["{k}"]'
            meta.append(f'    ["{e["name"]}", {m}]')
    out.append("GVAR(settingMeta) = createHashMapFromArray [")
    out.append(",\n".join(meta))
    out.append("];")
    out.append("")
    out.append("// Settings groups for the Zeus settings module: [title key, [names]]")
    groups = []
    for key, _title, settings in CATS:
        names = ", ".join(f'"{e["name"]}"' for e in settings)
        groups.append(f'    [LSTRING(cat_{key}), [{names}]]')
    out.append("GVAR(settingGroups) = [")
    out.append(",\n".join(groups))
    out.append("];")
    out.append("")
    out.append("// Feature switches for the Zeus toggle module and setFeatureEnabled: [setting, label key]")
    out.append("GVAR(featureSettings) = [")
    out.append(",\n".join(f'    ["{n}", LSTRING(feature_{n})]' for n, _ in FEATURES))
    out.append("];")
    return "\n".join(out) + "\n"


def strings():
    keys = dict(EXTRA)
    for n, label in FEATURES:
        keys[f"feature_{n}"] = label
    for key, title, settings in CATS:
        keys[f"cat_{key}"] = title
        for e in settings:
            keys[e["name"]] = e["title"]
            keys[e["name"] + "_desc"] = e["tip"]
            if e["kind"] == "LIST":
                for i, (label, _t) in enumerate(e["options"]):
                    keys[f"{e['name']}_opt{i}"] = label
    return keys


def build_xml(keys):
    out = ['<?xml version="1.0" encoding="utf-8"?>', '<Project name="azeroot_ronim">', '    <Package name="main">']
    for k in sorted(keys, key=str.lower):
        out.append(f'        <Key ID="STR_azeroot_ronim_main_{k}">')
        out.append(f'            <English>{html.escape(keys[k], quote=False)}</English>')
        out.append('        </Key>')
    out += ['    </Package>', '</Project>']
    return "\n".join(out) + "\n"


def build_attrs():
    """3DEN attributes; every attribute is RONIM_S_<setting>, Keep = -1 (numbers) or "" (text)."""
    out = ["// Generated by tools/gen_settings.py - edit the table there, not this file."]
    for _key, title, settings in CATS:
        out.append(f"// {title}")
        for e in settings:
            n = e["name"]
            label = f'"$STR_azeroot_ronim_main_{n}"'
            desc = f'"$STR_azeroot_ronim_main_{n}_desc"'
            cls = f"RONIM_S_{n}"
            k = e["kind"]
            if k == "CHECKBOX":
                out.append(f"ATTR_TRI({cls},{label},{desc});")
            elif k == "SLIDER":
                out.append(f"ATTR_NUM({cls},{label},{desc});")
            elif k == "EDITBOX":
                out.append(f"ATTR_STR({cls},{label},{desc});")
            else:
                vals = "".join(
                    f' class V{v} {{ name = "$STR_azeroot_ronim_main_{n}_opt{i}"; value = {v}; }};'
                    for i, v in enumerate(e["values"])
                )
                out.append(f"class {cls}: Combo {{ property = \"{cls}\"; displayName = {label}; tooltip = {desc}; "
                           f"typeName = \"NUMBER\"; defaultValue = -1; class Values {{ class Keep {{ name = ECSTRING(main,keep); value = -1; }};{vals} }}; }};")
    return "\n".join(out) + "\n"


def doc_default(e):
    k = e["kind"]
    if k == "CHECKBOX":
        return "on" if e["default"] else "off"
    if k == "EDITBOX":
        return f"`{e['default']}`" if e["default"] else "(empty)"
    if k == "SLIDER":
        return f"{round(e['default'] * 100, 1):g}%" if e["pct"] else num(e["default"])
    return e["options"][e["default"]][0]


def doc_range(e):
    k = e["kind"]
    if k == "SLIDER":
        return f"{round(e['lo'] * 100, 1):g}-{round(e['hi'] * 100, 1):g}%" if e["pct"] else f"{num(e['lo'])} - {num(e['hi'])}"
    if k == "LIST":
        return " / ".join(o[0] for o in e["options"])
    return ""


def build_md():
    out = [
        "# RONIM - CBA Settings",
        "",
        "<!-- generated by tools/gen_settings.py -->",
        "",
        "All settings live under **Addon Options > RONIM - Optic Nightvision**. Every value is read live, so a change "
        "made mid-mission applies at once. Settings marked *per player* are client settings; all others are mission/server "
        "settings the server can force.",
        "",
        "Runtime overrides from the Zeus/3DEN **RONIM Settings** modules or `azeroot_ronim_fnc_setOverride` take precedence "
        "until cleared. Variable names are `azeroot_ronim_main_<name>`.",
    ]
    for _key, title, settings in CATS:
        out += ["", f"## {title[3:]}", "", "| Setting | Name | Default | Range / options | What it does |", "|---|---|---|---|---|"]
        for e in settings:
            name = e["title"] + ("" if e["glob"] else " *(per player)*")
            desc = e["tip"].replace(NL, " ")
            out.append(f"| {name} | `{e['name']}` | {doc_default(e)} | {doc_range(e)} | {desc} |")
    return "\n".join(out) + "\n"


def write(rel, text):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote", rel)


if __name__ == "__main__":
    names = [e["name"] for _, _, s in CATS for e in s]
    assert len(names) == len(set(names)), "duplicate setting name"
    assert all(n in names for n, _ in FEATURES), "unknown feature setting"
    write("addons/main/initSettings.inc.sqf", build_sqf())
    write("addons/main/stringtable.xml", build_xml(strings()))
    write("addons/modules/settingsAttributes.inc.hpp", build_attrs())
    write("docs/SETTINGS.md", build_md())
    print(len(names), "settings")
