#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Local PiP cameras: follow the player's view (eye, or the optic while aiming) a little ahead to
 * clear the goggles / scope body and match the current zoom.
 *   cam:    night vision picture for the tubes (PiP tube modes)
 *   camEye: normal view for a monocular's naked eye while the tube uses the game's NVG mode
 * Created on demand, destroyed when not needed. Never networked.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _notIntegrated = !(GVAR(ads) && GVAR(integrated));
private _wantNv = GVAR(pipActive) && _notIntegrated;
private _wantEye = GVAR(eyePip) && _notIntegrated;

// [camera variable, wanted, render target, PiP effect]
private _cameras = [[QGVAR(cam), _wantNv, PIP_TARGET, 1], [QGVAR(camEye), _wantEye, PIP_TARGET_EYE, 0]];

private _origin = positionCameraToWorld [0, 0, 0];
private _dir = (positionCameraToWorld [0, 0, 1]) vectorDiff _origin;
private _up = (positionCameraToWorld [0, 1, 0]) vectorDiff _origin;
private _pos = AGLToASL (positionCameraToWorld [0, 0, [MSET(pipForwardHip), MSET(pipForwardAds)] select GVAR(ads)]);
private _fov = (0.75 / (GVAR(zoom) max 0.01)) * MSET(pipFovScale);

{
    _x params ["_var", "_want", "_target", "_effect"];
    private _cam = missionNamespace getVariable [_var, objNull];
    if (_want) then {
        if (isNull _cam) then {
            _cam = "camera" camCreate _origin;
            _cam cameraEffect ["INTERNAL", "BACK", _target];
            _target setPiPEffect [_effect];
            missionNamespace setVariable [_var, _cam];
        };
        _cam setPosASL _pos;
        _cam setVectorDirAndUp [_dir, _up];
        _cam camSetFov _fov;
        _cam camCommit 0;
    } else {
        if (!isNull _cam) then {
            _cam cameraEffect ["TERMINATE", "BACK", _target];
            camDestroy _cam;
            missionNamespace setVariable [_var, objNull];
        };
    };
} forEach _cameras;
