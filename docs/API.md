# RONIM - API

You can call every function from any machine. Functions that change mission state forward themselves to the server. Functions that act on a unit forward themselves to the machine where that unit is local.

## Functions

| Function | Arguments | Returns | Notes |
|---|---|---|---|
| `azeroot_ronim_fnc_setOverride` | `[name, value]` or `[[[name, value], ...]]` | - | Overrides a CBA setting for the mission. Names come from [SETTINGS.md](SETTINGS.md). A `nil` value clears the override. Runs on the server. |
| `azeroot_ronim_fnc_clearOverrides` | `[]` | - | Clears every override. Runs on the server. |
| `azeroot_ronim_fnc_setFeatureEnabled` | `[feature, bool or nil]` | BOOL | `feature` is one of `all`, `pip`, `mask`, `sway`, `adsSway`, `misalign`, `mount`, `bruise`, `flash`, `reticle`. `nil` goes back to the CBA setting. |
| `azeroot_ronim_fnc_setUnitExempt` | `[unit or units, exempt = true]` | - | An exempt unit gets no RONIM effects. |
| `azeroot_ronim_fnc_addIntegratedOptics` | `[class or classes]` | - | Optics treated as having integrated NV (features 2-6 off). Runs on the server. |
| `azeroot_ronim_fnc_removeIntegratedOptics` | `[class or classes]` | - | `[[]]` clears the API list. Runs on the server. |
| `azeroot_ronim_fnc_setTubeType` | `[nvgClass, "mono"/"bino"/"quad"/"none"/"auto"]` | - | Forces the tube layout. `none` makes RONIM ignore that NVG; `auto` removes the forced type. Runs on the server. |
| `azeroot_ronim_fnc_breakMount` | `[unit]` | BOOL | Drops the unit's NVGs to the ground. Runs where the unit is local. |
| `azeroot_ronim_fnc_reseatMount` | `[unit]` | - | Clears the mount misalignment. Runs where the unit is local. |
| `azeroot_ronim_fnc_getState` | `[unit = player]` | HASHMAP | Always returns `exempt`, `hmd`, `tube` and `live`. On the controlling player's machine it also returns `nvgOn`, `pip`, `ads`, `zoom`, `magnified`, `integrated`, `opticFeatures`, `misalign`, `flash` and `sway`. |

## CBA events

| Event | Scope | Arguments |
|---|---|---|
| `azeroot_ronim_main_mountBroken` | global | `[unit, nvgClass, weaponHolder]` |
| `azeroot_ronim_main_bruised` | local (player) | `[unit, damage]` |
| `azeroot_ronim_main_misaligned` | local (player) | `[unit, offset]` |
| `azeroot_ronim_main_reseated` | local (unit owner) | `[unit]` |
| `azeroot_ronim_main_flash` | local (player) | `[level]` |

## Config properties (for other mods)

```cpp
class CfgWeapons {
    class NVGoggles;
    class My_PVS14: NVGoggles {
        azeroot_ronim_tubeType = "mono";                 // mono / bino / quad / none (or 0-3)
        azeroot_ronim_mask[] = {2.2, 0, 0, 1};           // mask scale (screen heights), offset x, offset y, stretch
    };
    class optic_Base;
    class My_ACOG: optic_Base { azeroot_ronim_reticle = "chevron"; };  // dot / cross / chevron / mildot (or 0-3)
};
```

## Hooks

- `azeroot_ronim_main_bruiseFnc`: `{params ["_unit", "_damage"]}`, which applies a bruise. The ACE compat addon replaces it with ACE medical `punch` damage to the head.
