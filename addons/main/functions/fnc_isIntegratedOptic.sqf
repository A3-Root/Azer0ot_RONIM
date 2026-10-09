#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Whether the optic on the unit's current weapon (or the weapon itself, if no optic is attached)
 * has its own night vision or thermal. Such optics are excluded from the optic features.
 * Order: never-list, integrated list, API list, auto-detection from OpticsModes visionMode[].
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Integrated NV <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith { false };

private _optic = (_unit weaponAccessories _weapon) param [2, ""];
private _class = toLowerANSI ([_optic, _weapon] select (_optic == ""));

if (_class in (["integratedBlacklist"] call FUNC(classList))) exitWith { false };
if (_class in (["integratedWhitelist"] call FUNC(classList))) exitWith { true };
if (_class in GVAR(apiIntegrated)) exitWith { true };
if (!MSET(autoDetectIntegrated)) exitWith { false };

GVAR(cacheIntegrated) getOrDefaultCall [_class, {
    private _cfg = configFile >> "CfgWeapons" >> _class;
    private _modes = [_cfg >> "ItemInfo" >> "OpticsModes", _cfg >> "OpticsModes"] select (_optic == "");
    // An empty visionMode[] means the mode takes the goggles' vision, so only explicit NVG/TI counts
    (("true" configClasses _modes) findIf {
        private _vision = (getArray (_x >> "visionMode")) apply { toLowerANSI _x };
        "nvg" in _vision || {"ti" in _vision}
    }) != -1
}, true]
