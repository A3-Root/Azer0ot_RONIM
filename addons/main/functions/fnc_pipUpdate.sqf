#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Local night vision camera for PiP mode: follows the player's view (eye, or the optic while
 * aiming) a little ahead to clear the goggles / scope body, matches the current zoom, renders with
 * the PiP night vision effect. Created on demand, destroyed when not needed. Never networked.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _want = GVAR(pipActive) && {!(GVAR(ads) && GVAR(integrated))};

if (!_want) exitWith {
    if (!isNull GVAR(cam)) then {
        GVAR(cam) cameraEffect ["TERMINATE", "BACK", PIP_TARGET];
        camDestroy GVAR(cam);
        GVAR(cam) = objNull;
    };
};

if (isNull GVAR(cam)) then {
    GVAR(cam) = "camera" camCreate (positionCameraToWorld [0, 0, 0]);
    GVAR(cam) cameraEffect ["INTERNAL", "BACK", PIP_TARGET];
    PIP_TARGET setPiPEffect [1];
};

private _forward = [MSET(pipForwardHip), MSET(pipForwardAds)] select GVAR(ads);
private _origin = positionCameraToWorld [0, 0, 0];
private _dir = (positionCameraToWorld [0, 0, 1]) vectorDiff _origin;
private _up = (positionCameraToWorld [0, 1, 0]) vectorDiff _origin;

GVAR(cam) setPosASL AGLToASL (positionCameraToWorld [0, 0, _forward]);
GVAR(cam) setVectorDirAndUp [_dir, _up];
GVAR(cam) camSetFov ((0.75 / (GVAR(zoom) max 0.01)) * MSET(pipFovScale));
GVAR(cam) camCommit 0;
