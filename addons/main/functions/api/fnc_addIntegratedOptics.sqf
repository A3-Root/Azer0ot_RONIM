#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Marks optics (or weapons with built-in optics) as having integrated night vision for this
 * mission: no optic features while aiming through them. Adds to the CBA list, does not replace it.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Optic class or classes <STRING|ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["optic_Nightstalker"] call azeroot_ronim_fnc_addIntegratedOptics
 *
 * Public: Yes
 */

params [["_classes", [], ["", []]]];

if (!isServer) exitWith { [QGVAR(api), ["addIntegratedOptics", _this]] call CBA_fnc_serverEvent; };

if (_classes isEqualType "") then { _classes = [_classes]; };

private _list = +GVAR(apiIntegrated);
{
    if (_x isEqualType "") then { if (_x != "") then { _list pushBackUnique toLowerANSI _x; }; };
} forEach _classes;

missionNamespace setVariable [QGVAR(apiIntegrated), _list, true];
