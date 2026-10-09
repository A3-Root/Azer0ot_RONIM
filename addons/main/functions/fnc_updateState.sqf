#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Works out this frame's NVG / aiming state of the controlled unit.
 *
 * PiP mode (first person): RONIM owns the "NVG on" state and keeps the game's NVG mode off, so no
 * vanilla/ACE tube overlay or NVG post-process is drawn. The NVG key toggles RONIM's state
 * (fnc_onNvKey); a change of the game's mode RONIM did not cause (other mods, actions, a key the
 * key handler missed) counts as a toggle too. In third person the game's NVG mode follows RONIM's
 * state. Game mode (PiP off or unavailable): the game's NVG mode is used as is.
 *
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
if (_unit != GVAR(unit)) then {
    GVAR(nvRequested) = false;
    GVAR(engineOurs) = false;
};
GVAR(unit) = _unit;

private _hmd = hmd _unit;
if (_hmd != GVAR(hmd)) then {
    GVAR(hmd) = _hmd;
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
    GVAR(nvRequested) = false;
};

private _tube = [TUBE_NONE, [_hmd] call FUNC(getTubeType)] select (_hmd != "");
GVAR(tube) = _tube;

private _usable = _tube != TUBE_NONE
    && {alive _unit}
    && {isNull curatorCamera}
    && {!(_unit getVariable [QGVAR(exempt), false])}
    && {cameraOn == _unit || {MSET(allowVehicles) && {cameraOn == vehicle _unit} && {_unit call CBA_fnc_canUseWeapon}}};
private _firstPerson = cameraView in ["INTERNAL", "GUNNER"];
private _vision = currentVisionMode _unit;
private _pip = _usable && {MSET(pipEnabled)} && {isPiPEnabled};
private _settled = diag_tickTime > GVAR(engineCmdUntil);

if (_pip) then {
    private _changed = _vision != GVAR(lastVision) && _settled;
    private _keyed = diag_tickTime - GVAR(lastNvKey) < 0.5;
    if (!GVAR(pipUsed)) then {
        // Entering PiP: carry over the game's NVG state
        GVAR(pipUsed) = true;
        GVAR(nvRequested) = _vision == 1;
        GVAR(engineOurs) = _vision == 1;
        _changed = false;
    };
    // Thermal belongs to the goggles' own modes, RONIM stays out of it
    if (_vision == 2) exitWith {
        GVAR(nvRequested) = false;
        GVAR(engineOurs) = false;
    };
    if (_changed && !_keyed) then {
        // First person keeps the game mode off, so it coming on is a toggle; third person adopts it
        if (_firstPerson) then {
            if (_vision == 1 && !GVAR(engineOurs)) then { GVAR(nvRequested) = !GVAR(nvRequested); };
        } else {
            GVAR(nvRequested) = _vision == 1;
        };
        RLOG_1("NVG mode changed outside RONIM: PiP night vision %1",GVAR(nvRequested));
    };
    if (!_settled) exitWith {};
    // First person: game mode off. Third person: game mode follows RONIM's state.
    private _wantGame = GVAR(nvRequested) && !_firstPerson;
    if (_wantGame && _vision == 0) then {
        _unit action ["NVGoggles", _unit];
        GVAR(engineOurs) = true;
        GVAR(engineCmdUntil) = diag_tickTime + 0.25;
    };
    if (!_wantGame && _vision == 1) then {
        _unit action ["NVGogglesOff", _unit];
        GVAR(engineOurs) = false;
        GVAR(engineCmdUntil) = diag_tickTime + 0.25;
    };
} else {
    // Leaving PiP with NVGs on: hand the state back to the game's NVG mode
    if (GVAR(pipUsed) && GVAR(nvRequested) && _usable && _vision == 0) then {
        _unit action ["NVGoggles", _unit];
        GVAR(engineCmdUntil) = diag_tickTime + 0.3;
    };
    GVAR(pipUsed) = false;
    GVAR(nvRequested) = false;
    GVAR(engineOurs) = false;
};

GVAR(lastVision) = _vision;
GVAR(pipMode) = _pip;

private _wasOn = GVAR(nvgOn);
private _on = _usable && {[_vision == 1, GVAR(nvRequested)] select _pip};
GVAR(nvgOn) = _on;
GVAR(firstPerson) = _firstPerson;
GVAR(pipActive) = _on && _pip && _firstPerson;

if (_on && {!_wasOn} && {MSET(misalignToggleReset)}) then {
    GVAR(misalign) = [0, 0, 0];
    GVAR(recoverRate) = 0;
};

GVAR(zoom) = (0.75 call CBA_fnc_getFOV) select 1;
private _ads = _on && {cameraView == "GUNNER"};
GVAR(ads) = _ads;
GVAR(integrated) = _ads && {[_unit] call FUNC(isIntegratedOptic)};
GVAR(magnified) = _ads && {GVAR(zoom) >= MSET(magThreshold)};
GVAR(optActive) = GVAR(magnified) && {!GVAR(integrated)};
