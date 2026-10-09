#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Whether a unit's weapon has a suppressor fitted. A muzzle attachment counts when its
 * AmmoCoef audibleFire is below the suppressorAudible setting: flash hiders and brakes cut
 * visibleFire but not sound, so they still bloom. Suppressor lists override.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Weapon <STRING>
 *
 * Return Value:
 * Suppressed <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _muzzle = toLowerANSI ((_unit weaponAccessories _weapon) param [0, ""]);
if (_muzzle == "") exitWith { false };

if (_muzzle in (["suppressorBlacklist"] call FUNC(classList))) exitWith { false };
if (_muzzle in (["suppressorWhitelist"] call FUNC(classList))) exitWith { true };

private _audible = GVAR(cacheSupp) getOrDefaultCall [_muzzle, {
    private _cfg = configFile >> "CfgWeapons" >> _muzzle >> "ItemInfo" >> "AmmoCoef" >> "audibleFire";
    [1, getNumber _cfg] select isNumber _cfg
}, true];

_audible < MSET(suppressorAudible)
