#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Fired handler of the controlled unit: flash bloom, recoil kick, misalignment, bruise and
 * mount failure. Everything but the bloom needs optActive (NVGs on, magnified, not integrated).
 *
 * Arguments:
 * Fired event handler arguments
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_weapon", "", "", "_ammo"];

if (!GVAR(nvgOn) || {_weapon in ["Throw", "Put"]}) exitWith {};

private _rf = [_ammo] call FUNC(recoilFactor);
private _opt = GVAR(optActive);
GVAR(lastShot) = time;
GVAR(recoverRate) = 0;

if (
    MSET(flashEnabled)
    && {_opt || {!MSET(flashRequireMagnified) && {!(GVAR(ads) && GVAR(integrated))}}}
    && {!([_unit, _weapon] call FUNC(isSuppressed))}
) then {
    [1] call FUNC(flashBloom);
};

if (!_opt) exitWith {};

// Recoil knocks the tube, mostly upward
if (MSET(adsSwayEnabled)) then {
    private _kick = 0.15 * MSET(recoilKick) * _rf;
    GVAR(swayVel) = GVAR(swayVel) vectorAdd [random [-0.6, 0, 0.6] * _kick, -(0.6 + random 0.6) * _kick, 0];
};

private _shake = MSET(recoilCamShake);
if (_shake > 0) then { addCamShake [_shake * _rf, 0.3, 25]; };

if (MSET(misalignEnabled) && {random 1 < MSET(misalignChance) * _rf}) then {
    private _angle = random 360;
    private _step = MSET(misalignStep);
    private _new = GVAR(misalign) vectorAdd [sin _angle * _step, cos _angle * _step, 0];
    private _max = MSET(misalignMax);
    private _mag = vectorMagnitude _new;
    if (_mag > _max) then { _new = _new vectorMultiply (_max / _mag); };
    GVAR(misalign) = _new;
    [QGVAR(misaligned), [_unit, vectorMagnitude _new]] call CBA_fnc_localEvent;
    RLOG_1("misaligned, offset %1",vectorMagnitude _new);
};

if (MSET(bruiseEnabled)) then { [_unit, _rf] call FUNC(bruise); };

// Last: removes the goggles
if (MSET(mountEnabled) && {!(toLowerANSI hmd _unit in (["nvgImmune"] call FUNC(classList)))}) then {
    private _chance = MSET(mountChance) * ([1, _rf] select MSET(mountRecoilScale));
    if (random 1 < _chance) then { [_unit] call API(breakMount); };
};
