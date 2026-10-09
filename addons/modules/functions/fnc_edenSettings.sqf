#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * 3DEN: mission-wide overrides of RONIM's CBA settings. Every attribute is RONIM_S_<setting>;
 * "Keep setting" (-1, or empty text) leaves the CBA value alone.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer || {!_activated}) exitWith {};

private _meta = missionNamespace getVariable [QMVAR(settingMeta), createHashMap];
private _pairs = [];
{
    private _name = _x;
    private _info = _y;
    private _value = _logic getVariable ["RONIM_S_" + _name, nil];
    if (!isNil "_value") then {
        switch (_info select 0) do {
            case "CHECKBOX": {
                if (_value isEqualTo 0 || _value isEqualTo 1) then { _pairs pushBack [_name, _value == 1]; };
            };
            case "SLIDER": {
                if (_value isEqualType 0 && {_value != -1}) then {
                    _info params ["", "_min", "_max", "_decimals", "_percent"];
                    _value = (_value max _min) min _max;
                    if (_decimals == 0 && {!_percent}) then { _value = round _value; };
                    _pairs pushBack [_name, _value];
                };
            };
            case "LIST": {
                if (_value isEqualType 0 && {_value in (_info select 1)}) then { _pairs pushBack [_name, _value]; };
            };
            default {
                if (_value isEqualType "" && {count _value > 0}) then { _pairs pushBack [_name, _value]; };
            };
        };
    };
} forEach _meta;

if (_pairs isNotEqualTo []) then {
    [_pairs] call API(setOverride);
    if (MSET(debugLog)) then { diag_log text format ["[RONIM] 3DEN settings applied %1 overrides: %2", count _pairs, _pairs]; };
};
