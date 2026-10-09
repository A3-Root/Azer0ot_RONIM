#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Client init: state, caches, player event handlers and the per-frame loop.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// Frame state (written by updateState, read everywhere)
GVAR(unit) = objNull;
GVAR(hmd) = "";
GVAR(tube) = TUBE_NONE;
GVAR(nvgOn) = false;
GVAR(ads) = false;
GVAR(zoom) = 1;
GVAR(magnified) = false;
GVAR(integrated) = false;
GVAR(optActive) = false;

// Sway and effect state. Offsets are fractions of screen height, [x, y, 0], y down.
GVAR(swayPos) = [0, 0, 0];
GVAR(swayVel) = [0, 0, 0];
GVAR(misalign) = [0, 0, 0];
GVAR(recoverRate) = 0;
GVAR(lastDir) = [0, 1, 0];
GVAR(time) = 0;
GVAR(bobPhase) = 0;
GVAR(lastShot) = -1e6;
GVAR(bruiseNext) = 0;
GVAR(flashLevel) = 0;
GVAR(ppFlash) = -1;
GVAR(displayShown) = false;
GVAR(aimCoefSet) = false;
GVAR(debugNext) = 0;

GVAR(ehUnit) = objNull;
GVAR(ehFired) = -1;
GVAR(ehFiredNear) = -1;

// Follows respawn, team switch and Zeus remote control
["unit", {
    params ["_new"];
    [_new] call FUNC(attachHandlers);
    GVAR(misalign) = [0, 0, 0];
    GVAR(swayPos) = [0, 0, 0];
    GVAR(swayVel) = [0, 0, 0];
}, true] call CBA_fnc_addPlayerEventHandler;

[FUNC(tick), 0] call CBA_fnc_addPerFrameHandler;
