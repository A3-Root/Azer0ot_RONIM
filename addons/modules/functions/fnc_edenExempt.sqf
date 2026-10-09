#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * 3DEN: exempts synced units (and every unit of synced units' groups) from RONIM.
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

private _targets = [];
{
    { _targets pushBackUnique _x; } forEach units group _x;
} forEach (_units select { _x isKindOf "CAManBase" });

[_targets, _logic getVariable ["RONIM_E_value", true]] call API(setUnitExempt);
