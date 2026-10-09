# Changelog

## Test Round 4 (v1.0.0.4)

### Added
- NVG compat addons (generated): blank each NVG's own overlay, RONIM draws the same texture in front, swaying
- tools/gen_nvg_compat.py: scans a modpack for NVGs, re-run when NVG mods update
- Overlay size from the NVG's real optic model geometry (Optic overlay scale, default derived from the base game NVG)
- Custom monocular mask for every monocular NVG (toggle)

### Removed
- N/A

### Changed
- N/A

## Test Round 3 (v1.0.0.3)

### Added
- Tube mask shape read from the NVG at runtime: its own optic overlay texture (modelOptics), else ACE border, else RONIM's
- Mask calibration per NVG: Ctrl+Alt+Numpad keybinds (saved per player), server list, config property
- Mask drawn over the HUD layer, in front of the NVG's own overlay (toggle)
- Monocular other eye setting: dark or real view (PiP)
- NVG key handler for PiP mode; game NVG mode enforced each frame

### Removed
- N/A

### Changed
- PiP night vision off by default
- Monocular defaults to the right eye, shifted to the right half

## Test Round 2 (v1.0.0.2)

### Added
- PiP night vision: RONIM renders NV itself in first person, game NVG mode stays off (no vanilla/ACE tube overlay)
- Monocular PiP keeps the real view on the naked eye
- Reticle drawn over the NV picture while aiming; sway/misalignment move the picture against it
- PiP settings: resolution, camera offsets, FOV trim

### Removed
- N/A

### Changed
- Bruise picks ACE medical at call time (was falling back to vanilla); ACE damage min 0.11
- Sway defaults and maximums raised (strength, look, walk, idle, max offset, ADS sway, recoil kick, misalignment)
- Reticle category: overlay for all tube types in PiP, monocular side copy kept for game NVG mode

## Initial Release (v1.0.0.1)

### Added
- NVG tube mask (mono/bino/quad) with head-lag, walk-bob, idle/fatigue sway
- Independent ADS tube sway + recoil kick through magnified optics
- Mount misalignment; fixed by NVG toggle, auto recovery or ACE re-seat action
- Mount failure: NVGs drop to the ground
- Recoil head bruise (ACE contusion / vanilla head damage)
- Muzzle flash bloom for unsuppressed shots, optional nearby shooters
- Monocular reticle copy on the naked eye
- Integrated NV optic auto-detection + whitelist
- 70 CBA settings, Zeus (ZEN) and 3DEN modules, 3DEN unit attribute, public API

### Removed
- N/A

### Changed
- N/A
