#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus: pick a settings group, then edit its settings as mission overrides.
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

private _groups = missionNamespace getVariable [QMVAR(settingGroups), []];
private _values = [];
{ _values pushBack _forEachIndex; } forEach _groups;

[
    LELSTRING(main,zeus_settings),
    [
        ["COMBO", LELSTRING(main,pickCategory), [_values, _groups apply { localize (_x select 0) }, 0]]
    ],
    {
        params ["_results", "_groups"];
        (_groups select (_results select 0)) params ["_titleKey", "_names"];
        // Open the second dialog once the first one has closed
        [{ call FUNC(settingsDialog) }, [localize _titleKey, _names]] call CBA_fnc_execNextFrame;
    },
    {},
    _groups
] call zen_dialog_fnc_create;
