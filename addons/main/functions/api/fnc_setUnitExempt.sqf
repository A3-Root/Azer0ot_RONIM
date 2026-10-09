#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Exempts units from every RONIM effect (or lifts the exemption). Works from any machine.
 *
 * Arguments:
 * 0: Unit or units <OBJECT|ARRAY>
 * 1: Exempt <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, true] call azeroot_ronim_fnc_setUnitExempt
 * [units group player, false] call azeroot_ronim_fnc_setUnitExempt
 *
 * Public: Yes
 */

params [["_units", [], [objNull, []]], ["_exempt", true, [true]]];

if (_units isEqualType objNull) then { _units = [_units]; };

{
    if (!isNull _x) then { _x setVariable [QGVAR(exempt), _exempt, true]; };
} forEach _units;
