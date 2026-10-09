#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Works out this frame's NVG / aiming state of the controlled unit.
 * optActive = NVGs on, aiming through a magnified optic that has no night vision of its own:
 * the condition for every optic feature (mount failure, bruise, ADS sway, misalignment, reticle).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _unit = call CBA_fnc_currentUnit;
GVAR(unit) = _unit;

private _hmd = hmd _unit;
if (_hmd != GVAR(hmd)) then {
    GVAR(hmd) = _hmd;
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
};

private _tube = [TUBE_NONE, [_hmd] call FUNC(getTubeType)] select (_hmd != "");
GVAR(tube) = _tube;

private _wasOn = GVAR(nvgOn);
private _on = _tube != TUBE_NONE
    && {currentVisionMode _unit == 1}
    && {alive _unit}
    && {isNull curatorCamera}
    && {!(_unit getVariable [QGVAR(exempt), false])}
    && {cameraOn == _unit || {MSET(allowVehicles) && {cameraOn == vehicle _unit} && {_unit call CBA_fnc_canUseWeapon}}};
GVAR(nvgOn) = _on;

if (_on && {!_wasOn} && {MSET(misalignToggleReset)}) then {
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
};

private _ads = _on && {cameraView == "GUNNER"};
GVAR(ads) = _ads;
GVAR(zoom) = [1, (0.75 call CBA_fnc_getFOV) select 1] select _ads;
GVAR(integrated) = _ads && {[_unit] call FUNC(isIntegratedOptic)};
GVAR(magnified) = _ads && {GVAR(zoom) >= MSET(magThreshold)};
GVAR(optActive) = GVAR(magnified) && {!GVAR(integrated)};
