#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus dialog for a list of RONIM settings. Labels, tooltips, ranges and options come from the
 * setting definitions (same text as Addon Options); the current effective value is preselected.
 * Confirming applies them as mission overrides; the last checkbox clears these overrides instead.
 *
 * Arguments:
 * 0: Dialog title <STRING>
 * 1: Setting names <ARRAY of STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_title", "_names"];

private _meta = missionNamespace getVariable [QMVAR(settingMeta), createHashMap];
private _controls = [];
private _rows = [];

{
    private _name = _x;
    private _info = _meta getOrDefault [_name, []];
    if (_info isNotEqualTo []) then {
        private _value = [_name] call MFUNC(settingValue);
        private _label = [localize format ["STR_azeroot_ronim_main_%1", _name], localize format ["STR_azeroot_ronim_main_%1_desc", _name]];
        switch (_info select 0) do {
            case "CHECKBOX": { _controls pushBack ["CHECKBOX", _label, _value]; };
            case "SLIDER": {
                _info params ["", "_min", "_max", "_decimals", "_percent"];
                if (_percent) then {
                    _controls pushBack ["SLIDER:PERCENT", _label, [_min, _max, _value, _decimals]];
                } else {
                    _controls pushBack ["SLIDER", _label, [_min, _max, _value, _decimals]];
                };
            };
            case "LIST": {
                _info params ["", "_values", "_labels"];
                _controls pushBack ["COMBO", _label, [_values, _labels apply { localize _x }, (_values find _value) max 0]];
            };
            default { _controls pushBack ["EDIT", _label, [_value]]; };
        };
        _rows pushBack [_name, _info];
    };
} forEach _names;
_controls pushBack ["CHECKBOX", [LELSTRING(main,clearOverrides), LELSTRING(main,clearOverrides_desc)], false];

[
    _title,
    _controls,
    {
        params ["_results", "_rows"];
        if (_results deleteAt (count _results - 1)) exitWith {
            [_rows apply { [_x select 0, nil] }] call API(setOverride);
            [LELSTRING(main,msgCleared)] call zen_common_fnc_showMessage;
        };
        private _pairs = [];
        {
            _x params ["_name", "_info"];
            private _value = _results select _forEachIndex;
            if ((_info select 0) == "SLIDER" && {(_info select 3) == 0} && {!(_info select 4)}) then { _value = round _value; };
            _pairs pushBack [_name, _value];
        } forEach _rows;
        [_pairs] call API(setOverride);
        [LELSTRING(main,msgApplied)] call zen_common_fnc_showMessage;
    },
    {},
    _rows
] call zen_dialog_fnc_create;
