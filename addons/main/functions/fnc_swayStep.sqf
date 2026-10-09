#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Advances the tube sway: a damped spring pulls the tube toward a target built from head turn
 * lag, walking bob, idle/fatigue drift, the independent ADS channel and the mount misalignment.
 * Recoil (fnc_onFired) kicks the spring velocity directly. Also settles misalignment back.
 * Offsets are fractions of screen height, [x, y, 0], y down.
 *
 * Arguments:
 * 0: Frame time <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_dt"];

private _unit = GVAR(unit);
private _dir = getCameraViewDirection _unit;
private _lastDir = GVAR(lastDir);
GVAR(lastDir) = _dir;

if (!GVAR(nvgOn) || _dt <= 0) exitWith {
    GVAR(swayPos) = [0, 0, 0];
    GVAR(swayVel) = [0, 0, 0];
};

// Misalignment settles back after a quiet period, at a rate that clears it in misalignRecoverTime
if (MSET(misalignAutoRecover) && {GVAR(misalign) isNotEqualTo [0, 0, 0]} && {time - GVAR(lastShot) > MSET(misalignRecoverDelay)}) then {
    private _mag = vectorMagnitude GVAR(misalign);
    if (GVAR(recoverRate) <= 0) then { GVAR(recoverRate) = _mag / (MSET(misalignRecoverTime) max 0.1); };
    private _left = _mag - GVAR(recoverRate) * _dt;
    if (_left <= 0 || _mag == 0) then {
        GVAR(misalign) = [0, 0, 0];
        GVAR(recoverRate) = 0;
    } else {
        GVAR(misalign) = GVAR(misalign) vectorMultiply (_left / _mag);
    };
};

if (!MSET(swayEnabled)) exitWith {
    GVAR(swayPos) = +GVAR(misalign);
    GVAR(swayVel) = [0, 0, 0];
};

GVAR(time) = GVAR(time) + _dt;
private _t = GVAR(time);
private _fatigue = (getFatigue _unit) max (_unit getVariable ["ace_advanced_fatigue_aimFatigue", 0]);
private _tx = 0;
private _ty = 0;

// Head turn lag: the tube trails the rotation (deg/s), yaw right -> tube left, pitch up -> tube down
private _yawRate = ((_dir select 0) atan2 (_dir select 1)) - ((_lastDir select 0) atan2 (_lastDir select 1));
if (_yawRate > 180) then { _yawRate = _yawRate - 360; };
if (_yawRate < -180) then { _yawRate = _yawRate + 360; };
_yawRate = ((_yawRate / _dt) max -400) min 400;
private _pitchRate = (((asin (((_dir select 2) max -1) min 1)) - (asin (((_lastDir select 2) max -1) min 1))) / _dt) max -400 min 400;
private _look = 0.0006 * MSET(swayLook);
_tx = _tx - _yawRate * _look;
_ty = _ty + _pitchRate * _look;

// Walking bob: figure of eight, frequency and size grow with speed, smaller when low
private _speed = (vectorMagnitude velocity _unit) min 7;
if (_speed > 0.2) then {
    private _stance = ["STAND", "CROUCH", "PRONE"] find stance _unit;
    private _stanceMul = [1, 0.6, 0.25] select (_stance max 0);
    GVAR(bobPhase) = (GVAR(bobPhase) + 360 * (1.6 + _speed * 0.18) * _dt) mod 720;
    private _amp = 0.0022 * _speed * _stanceMul * MSET(swayMove);
    _tx = _tx + sin GVAR(bobPhase) * _amp;
    _ty = _ty + cos (2 * GVAR(bobPhase)) * _amp * 0.5;
};

// Idle drift and breathing, larger when tired
private _idle = 0.0018 * MSET(swayIdle) * (1 + _fatigue * 3 * MSET(swayFatigue));
_tx = _tx + (sin (_t * 37) + 0.6 * sin (_t * 83 + 40)) * _idle;
_ty = _ty + (sin (_t * 29 + 120) + 0.5 * sin (_t * 61) + 0.8 * sin (_t * 90)) * _idle;

// Independent ADS channel: out of step with the weapon sway so the tube and sight wander apart
if (GVAR(optActive) && {MSET(adsSwayEnabled)}) then {
    private _ads = 0.005 * MSET(adsSwayStrength) * (1 + _fatigue * MSET(swayFatigue));
    _tx = _tx + (sin (_t * 71 + 10) + 0.7 * sin (_t * 131 + 77) + 0.3 * sin (_t * 211)) * _ads;
    _ty = _ty + (sin (_t * 59 + 200) + 0.6 * sin (_t * 149 + 33)) * _ads;
};

private _strength = MSET(swayStrength);
private _target = [_tx * _strength, _ty * _strength, 0] vectorAdd GVAR(misalign);

// Damped spring, fixed sub-steps for stability at low frame rates
private _k = MSET(swayStiffness);
private _c = MSET(swayDamping);
private _pos = GVAR(swayPos);
private _vel = GVAR(swayVel);
private _steps = ceil (_dt / 0.02);
private _h = _dt / _steps;
for "_i" from 1 to _steps do {
    private _acc = ((_target vectorDiff _pos) vectorMultiply _k) vectorDiff (_vel vectorMultiply _c);
    _vel = _vel vectorAdd (_acc vectorMultiply _h);
    _pos = _pos vectorAdd (_vel vectorMultiply _h);
};

private _max = MSET(swayMaxOffset) + vectorMagnitude GVAR(misalign);
private _mag = vectorMagnitude _pos;
if (_mag > _max) then {
    _pos = _pos vectorMultiply (_max / _mag);
    _vel = _vel vectorMultiply 0.5;
};

GVAR(swayPos) = _pos;
GVAR(swayVel) = _vel;
