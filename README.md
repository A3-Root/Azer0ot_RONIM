# Azer0ot_RONIM

![version](https://img.shields.io/badge/version-1.0.0.1-blue)
[![build](https://github.com/A3-Root/Azer0ot_RONIM/actions/workflows/auto-release.yml/badge.svg?branch=master)](https://github.com/A3-Root/Azer0ot_RONIM/actions/workflows/auto-release.yml)

**RONIM - Realistic Optic Nightvision Integration Mechanism** makes NVGs behave like real tubes, most of all when you aim through a magnified optic with them.

Authors: **Root, Azer0**. Requires **CBA**. **ACE** and **ZEN** are optional; RONIM uses them when they are loaded.

## Features

| # | Feature | When |
|---|---|---|
| 1 | **Tube viewport and sway.** RONIM draws the NVG tubes (monocular, binocular or quad). The view lags behind head turns, bobs as you walk and drifts more as you tire. | NVGs on |
| 2 | **Mount failure.** A shot can break the mount, and the goggles fall to the ground. Stronger rounds break it more often. | magnified optic |
| 3 | **Recoil bruise.** Recoil can push the NVG into your face and cause a head contusion (ACE medical) or minor head damage (vanilla). There is a cooldown between bruises. | magnified optic |
| 4 | **Independent ADS sway and misalignment.** The tubes sway out of step with the weapon, and recoil knocks them. A shot can shift the mount off centre. The mount is fixed by toggling the NVGs, by recovering on its own over about 5.5 s, or with the ACE self-action *Re-seat NVG mount* (about 5.5 s). | magnified optic |
| 5 | **Muzzle flash bloom.** An unsuppressed shot washes the image out white for a moment. Unsuppressed shots from nearby units can do the same (optional). Flash hiders do not count as suppressors. | magnified optic (configurable) |
| 6 | **Monocular reticle.** With a monocular, a copy of the scope reticle (dot, cross, chevron or mil-dot, set per optic) is drawn on the eye without the tube. | magnified optic + monocular |

"Magnified optic" means aiming with NVGs on through an optic at or above the magnification threshold (default 1.5x). Iron sights and holo sights only get feature 1. Optics with their own NVG or thermal mode, whether auto-detected or listed, get none of features 2-6.

## Configuration

- **CBA settings:** 70 settings under *Addon Options > RONIM - Optic Nightvision*. See [docs/SETTINGS.md](docs/SETTINGS.md).
- **Zeus (ZEN):** settings, feature toggles, exempt unit, break mount, re-seat mount, integrated optics. See [docs/MODULES.md](docs/MODULES.md).
- **3DEN:** the *RONIM Settings* module, the *RONIM Exempt Units* module, and a unit attribute *RONIM: exempt*.
- **API:** `azeroot_ronim_fnc_*` functions and CBA events. See [docs/API.md](docs/API.md).

## ACE notes

- ACE Nightvision draws its own fixed tube mask. RONIM hides it and draws its own instead. You can change this with the *ACE NVG mask handling* setting.
- ACE's own `ace_nightvision_shutterEffects` blink stacks with RONIM's bloom. Turn one of them off if you only want one.
- `ace_nightvision_disableNVGsWithSights` turns NVGs off while aiming, which leaves features 2-6 nothing to act on.

## Building

```
python tools/gen_settings.py    # after editing the settings table
python tools/gen_textures.py    # after editing masks / reticles (numpy, Pillow)
hemtt ln sort
hemtt check -p -Lc14 -e
hemtt release
```
