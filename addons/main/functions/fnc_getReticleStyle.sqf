#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Monocular reticle style for the optic on the unit's current weapon.
 * Order: Classes > Reticle per optic (class:style), config property azeroot_ronim_reticle on
 * the optic (style name or 0-3), then the default reticle setting.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Style index into RETICLE_STYLES <NUMBER>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;
private _optic = (_unit weaponAccessories _weapon) param [2, ""];
private _class = toLowerANSI ([_optic, _weapon] select (_optic == ""));
private _map = ["reticleMap"] call FUNC(settingValue);
private _default = MSET(reticleStyle);

GVAR(cacheReticle) getOrDefaultCall [format ["%1|%2|%3", _map, _class, _default], {
    private _style = -1;
    {
        private _pair = _x splitString ":";
        if (count _pair == 2 && {toLowerANSI (_pair select 0) == _class}) exitWith {
            _style = RETICLE_STYLES find toLowerANSI (_pair select 1);
        };
    } forEach (_map splitString ", ;");

    if (_style == -1) then {
        private _prop = configFile >> "CfgWeapons" >> _class >> "azeroot_ronim_reticle";
        if (isNumber _prop) then { _style = (round getNumber _prop) max 0 min 3; };
        if (isText _prop) then { _style = RETICLE_STYLES find toLowerANSI getText _prop; };
    };

    [_style, _default] select (_style == -1)
}, true]
