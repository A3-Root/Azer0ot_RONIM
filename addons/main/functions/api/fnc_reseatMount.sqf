#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Re-seats a unit's NVG mount: clears its misalignment at once.
 * Raises the local CBA event "azeroot_ronim_main_reseated" [unit] on the unit's machine.
 * Runs where the unit is local (forwarded automatically).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call azeroot_ronim_fnc_reseatMount
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};
if (!local _unit) exitWith { [QGVAR(reseatMount), [_unit], _unit] call CBA_fnc_targetEvent; };

if (hasInterface && {_unit == call CBA_fnc_currentUnit}) then {
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
};

[QGVAR(reseated), [_unit]] call CBA_fnc_localEvent;
