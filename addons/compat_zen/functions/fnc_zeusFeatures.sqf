#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus: switch RONIM features on/off for the mission, or back to their CBA setting.
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
deleteVehicle _logic;

private _features = missionNamespace getVariable [QMVAR(featureSettings), []];
private _labels = [LELSTRING(main,keep), LELSTRING(main,off), LELSTRING(main,on)];
private _controls = _features apply {
    _x params ["_name", "_labelKey"];
    private _override = missionNamespace getVariable ["azeroot_ronim_main_ov_" + _name, nil];
    private _index = if (isNil "_override") then { 0 } else { [1, 2] select _override };
    ["COMBO", localize _labelKey, [[-1, 0, 1], _labels, _index]]
};

[
    LELSTRING(main,featuresTitle),
    _controls,
    {
        params ["_results", "_features"];
        {
            private _choice = _results select _forEachIndex;
            if (_choice == -1) then {
                [_x select 0] call API(setFeatureEnabled);
            } else {
                [_x select 0, _choice == 1] call API(setFeatureEnabled);
            };
        } forEach _features;
        [LELSTRING(main,msgFeatures)] call zen_common_fnc_showMessage;
    },
    {},
    _features
] call zen_dialog_fnc_create;
