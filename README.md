# Azer0ot_RONIM

![version](https://img.shields.io/badge/version-1.0.0.5-blue)
[![build](https://github.com/A3-Root/Azer0ot_RONIM/actions/workflows/auto-release.yml/badge.svg?branch=master)](https://github.com/A3-Root/Azer0ot_RONIM/actions/workflows/auto-release.yml)

**RONIM - Realistic Optic Nightvision Integration Mechanism** makes NVGs behave like real tubes, most of all when you aim through a magnified optic with them.

Authors: **Root, Azer0**. Requires **CBA**. **ACE** and **ZEN** are optional; RONIM uses them when they are loaded.

## Features

| # | Feature | When |
|---|---|---|
| 1 | **Tube overlay and sway.** RONIM draws the NVG's tubes in front of the game's NVG view. It takes the shape from the NVG itself at runtime (its own optic overlay texture, else its ACE border, else RONIM's monocular/binocular/quad mask). The tubes lag behind head turns, bob as you walk and drift more as you tire. A monocular covers one eye (right by default) and leaves the rest dark. Optionally (off by default), *PiP night vision* has RONIM render the night vision itself in first person and keep the game's NVG mode off; a PiP monocular can leave the other eye with the real view. | NVGs on |
| 2 | **Mount failure.** A shot can break the mount, and the goggles fall to the ground. Stronger rounds break it more often. | magnified optic |
| 3 | **Recoil bruise.** Recoil can push the NVG into your face and cause a head contusion (ACE medical) or minor head damage (vanilla). There is a cooldown between bruises. | magnified optic |
| 4 | **Independent ADS sway and misalignment.** The tubes sway out of step with the weapon, and recoil knocks them. A shot can shift the mount off centre. The mount is fixed by toggling the NVGs, by recovering on its own over about 5.5 s, or with the ACE self-action *Re-seat NVG mount* (about 5.5 s). | magnified optic |
| 5 | **Muzzle flash bloom.** An unsuppressed shot washes the image out white for a moment. Unsuppressed shots from nearby units can do the same (optional). Flash hiders do not count as suppressors. | magnified optic (configurable) |
| 6 | **Reticle.** The NV picture covers the scope, so the optic's reticle (dot, cross, chevron or mil-dot, set per optic) is drawn on top at the aim point. Sway and misalignment move the picture against it. In game NVG mode a monocular gets a copy of the reticle on the eye without the tube. | magnified optic |

"Magnified optic" means aiming with NVGs on through an optic at or above the magnification threshold (default 1.5x). Iron sights and holo sights only get feature 1. Optics with their own NVG or thermal mode, whether auto-detected or listed, get none of features 2-6.

## Configuration

- **CBA settings:** 86 settings under *Addon Options > RONIM - Optic Nightvision*. See [docs/SETTINGS.md](docs/SETTINGS.md).
- **Zeus (ZEN):** settings, feature toggles, exempt unit, break mount, re-seat mount, integrated optics. See [docs/MODULES.md](docs/MODULES.md).
- **3DEN:** the *RONIM Settings* module, the *RONIM Exempt Units* module, and a unit attribute *RONIM: exempt*.
- **API:** `azeroot_ronim_fnc_*` functions and CBA events. See [docs/API.md](docs/API.md).

## NVG overlay compat

The game draws an NVG's own optic overlay (its `modelOptics`) above every script UI layer, so RONIM can't draw in front of it. The fix is a config patch, and a config patch has to name each class. `tools/gen_nvg_compat.py` scans the modpack and writes one `addons/compat_nvg_<pbo>` addon per mod. Each one:

- blanks every NVG's `modelOptics`, so the game no longer draws it,
- stores the overlay's texture and its textured-quad geometry for RONIM, which then draws the same picture itself, in front and swaying,
- only loads when its mod is loaded (`skipWhenMissingDependencies`).

Re-run it whenever an NVG mod updates or a new one is added:

```
python tools/gen_nvg_compat.py "<Arma 3>" "<Arma 3>\@mod1" "<Arma 3>\@mod2" ...
```

On-screen size comes from the model geometry and one global value, *Optic overlay scale*. Its default, 19.41, comes from the base game NVG overlay, which is exactly one 4:3 screen in model units. Monocular NVGs use RONIM's own monocular mask by default (*Custom monocular mask*).

## Fine-tuning the mask

- In game, with NVGs on, hold **Ctrl+Alt+Numpad** keys: `+`/`-` size, `8`/`2` up/down, `4`/`6` left/right, `9`/`7` wider/narrower, `5` reset. You can rebind them under *Controls > Configure Addons > RONIM*.
- The value is saved in your profile. The hint shows a `class:scale:x:y:stretch` entry you can paste into *Classes > Mask calibration* so the server applies it for everyone.
- Mod authors can set `azeroot_ronim_mask[] = {scale, x, y, stretch};` on the NVG class.

## ACE notes

- With PiP night vision on, the game's NVG mode stays off, so ACE Nightvision's grain, blur and mask only apply in third person or with PiP off.
- In game NVG mode, ACE Nightvision draws its own fixed tube mask. RONIM hides it and draws its own instead. You can change this with the *ACE NVG mask handling* setting.
- ACE's own `ace_nightvision_shutterEffects` blink stacks with RONIM's bloom. Turn one of them off if you only want one.
- `ace_nightvision_disableNVGsWithSights` turns NVGs off while aiming, which leaves features 2-6 nothing to act on.

## Building

```
python tools/gen_settings.py    # after editing the settings table
python tools/gen_textures.py    # after editing masks / reticles (numpy, Pillow)
python tools/gen_nvg_compat.py "<Arma 3>" "<Arma 3>\@mod" ...   # after NVG mods change
hemtt ln sort
hemtt check -p -Lc14 -e
hemtt release
```
