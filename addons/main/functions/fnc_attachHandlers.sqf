#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Moves the Fired / FiredNear handlers to the unit the player now controls.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (!isNull GVAR(ehUnit)) then {
    GVAR(ehUnit) removeEventHandler ["Fired", GVAR(ehFired)];
    GVAR(ehUnit) removeEventHandler ["FiredNear", GVAR(ehFiredNear)];
};

GVAR(ehUnit) = _unit;
if (isNull _unit) exitWith {};

GVAR(ehFired) = _unit addEventHandler ["Fired", { call FUNC(onFired) }];
GVAR(ehFiredNear) = _unit addEventHandler ["FiredNear", { call FUNC(onFiredNear) }];
