#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Removes optics added with azeroot_ronim_fnc_addIntegratedOptics. Empty array clears all.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Optic class or classes <STRING|ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["optic_Nightstalker"] call azeroot_ronim_fnc_removeIntegratedOptics
 * [[]] call azeroot_ronim_fnc_removeIntegratedOptics
 *
 * Public: Yes
 */

params [["_classes", [], ["", []]]];

if (!isServer) exitWith { [QGVAR(api), ["removeIntegratedOptics", _this]] call CBA_fnc_serverEvent; };

if (_classes isEqualType "") then { _classes = [_classes]; };

private _list = [];
if (_classes isNotEqualTo []) then {
    private _remove = _classes apply { toLowerANSI _x };
    _list = GVAR(apiIntegrated) select { !(_x in _remove) };
};

missionNamespace setVariable [QGVAR(apiIntegrated), _list, true];
