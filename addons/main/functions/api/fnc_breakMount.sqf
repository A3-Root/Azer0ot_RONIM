#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Breaks a unit's NVG mount: the goggles are removed and drop to the ground in front of it.
 * Raises the global CBA event "azeroot_ronim_main_mountBroken" [unit, nvgClass, holder].
 * Runs where the unit is local (forwarded automatically).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Goggles dropped (false when forwarded or no NVG) <BOOL>
 *
 * Example:
 * [player] call azeroot_ronim_fnc_breakMount
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit}) exitWith { false };
if (!local _unit) exitWith {
    [QGVAR(breakMount), [_unit], _unit] call CBA_fnc_targetEvent;
    false
};

private _hmd = hmd _unit;
if (_hmd == "") exitWith { false };

if (currentVisionMode _unit == 1) then { _unit action ["NVGogglesOff", _unit]; };
_unit unlinkItem _hmd;

private _holder = createVehicle ["WeaponHolderSimulated", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_holder addItemCargoGlobal [_hmd, 1];
_holder setPosWorld ((eyePos _unit) vectorAdd (_unit vectorModelToWorldVisual [0, 0.25, 0.05]));
_holder setDir random 360;
_holder setVelocity ((velocity _unit) vectorAdd (_unit vectorModelToWorldVisual [random [-0.8, 0, 0.8], 0.6 + random 0.8, 0.4]));

if (hasInterface && {_unit == call CBA_fnc_currentUnit}) then {
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
    if (MSET(mountNotify)) then { hintSilent localize LSTRING(mountBrokenHint); };
};

[QGVAR(mountBroken), [_unit, _hmd, _holder]] call CBA_fnc_globalEvent;
RLOG_2("mount broken: %1 dropped %2",_unit,_hmd);
true
