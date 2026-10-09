#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Removes every runtime setting override, returning to the CBA setting values.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call azeroot_ronim_fnc_clearOverrides
 *
 * Public: Yes
 */

if (!isServer) exitWith { [QGVAR(api), ["clearOverrides", []]] call CBA_fnc_serverEvent; };

{
    missionNamespace setVariable [QUOTE(ADDON) + "_ov_" + _x, nil, true];
} forEach (missionNamespace getVariable [QGVAR(overrideNames), []]);

missionNamespace setVariable [QGVAR(overrideNames), [], true];
