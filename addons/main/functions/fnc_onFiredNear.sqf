#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * FiredNear handler of the controlled unit: unsuppressed shots from other units close by and
 * in view bloom the NVGs, fading with distance and with distance from screen centre.
 *
 * Arguments:
 * FiredNear event handler arguments
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_firer", "_distance", "_weapon"];

if (
    !MSET(flashNearby)
    || {!MSET(flashEnabled)}
    || {!GVAR(nvgOn)}
    || _firer == _unit
    || {!(_firer isKindOf "CAManBase")}
    || {_weapon in ["Throw", "Put"]}
) exitWith {};
if (MSET(flashRequireMagnified) && {!GVAR(optActive)}) exitWith {};
if (GVAR(ads) && GVAR(integrated)) exitWith {};

private _range = MSET(flashNearbyRange);
if (_distance > _range) exitWith {};
if ([_firer, _weapon] call FUNC(isSuppressed)) exitWith {};

// Behind you = no bloom; at the screen edge = little
private _screen = worldToScreen ASLToAGL eyePos _firer;
if (_screen isEqualTo []) exitWith {};
private _view = (1 - ((_screen distance2D [0.5, 0.5]) / 0.8)) max 0;

private _intensity = MSET(flashNearbyScale) * (1 - _distance / _range) * _view;
if (_intensity > 0.02) then { [_intensity] call FUNC(flashBloom); };
