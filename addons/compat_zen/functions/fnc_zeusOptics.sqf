#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus: add or remove optics treated as integrated NV for this mission. Placed on a unit, it can
 * add the optic on that unit's current weapon.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if (!hasInterface) exitWith {};
private _unit = attachedTo _logic;
deleteVehicle _logic;

private _controls = [
    ["EDIT", [LELSTRING(main,opticsAdd), LELSTRING(main,opticsAdd_desc)], [""]],
    ["EDIT", [LELSTRING(main,opticsRemove), LELSTRING(main,opticsRemove_desc)], [""]]
];
if (!isNull _unit) then {
    _controls pushBack ["CHECKBOX", [LELSTRING(main,opticsCurrent), LELSTRING(main,opticsCurrent_desc)], true];
};

[
    LELSTRING(main,zeus_optics),
    _controls,
    {
        params ["_results", "_unit"];
        _results params ["_add", "_remove", ["_current", false]];
        private _addList = _add splitString ", ;";
        if (_current && {!isNull _unit}) then {
            private _weapon = currentWeapon _unit;
            private _optic = (_unit weaponAccessories _weapon) param [2, ""];
            _addList pushBack ([_optic, _weapon] select (_optic == ""));
        };
        _addList = _addList select { _x != "" };
        if (_addList isNotEqualTo []) then { [_addList] call API(addIntegratedOptics); };
        private _removeList = _remove splitString ", ;";
        if (_removeList isNotEqualTo []) then { [_removeList] call API(removeIntegratedOptics); };
        [LELSTRING(main,msgOptics)] call zen_common_fnc_showMessage;
    },
    {},
    _unit
] call zen_dialog_fnc_create;
