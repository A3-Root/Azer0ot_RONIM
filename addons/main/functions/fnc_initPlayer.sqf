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
GVAR(firstPerson) = true;

// PiP night vision: RONIM's own NVG on/off state while the game's NVG mode stays off
GVAR(pipActive) = false;
GVAR(pipUsed) = false;
GVAR(nvRequested) = false;
GVAR(engineOurs) = false;
GVAR(engineCmdUntil) = 0;
GVAR(pipMode) = false;
GVAR(lastNvKey) = -1e6;
GVAR(lastVision) = 0;
GVAR(displayOverHud) = false;

// Mask calibration of this player, per NVG class: [scale, offsetX, offsetY, stretch]
GVAR(calibProfile) = createHashMapFromArray (profileNamespace getVariable [QGVAR(calibration), []]);
GVAR(calibSaveAt) = 0;
GVAR(cam) = objNull;
GVAR(camEye) = objNull;
GVAR(eyePip) = false;

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

// The NVG key itself, so PiP mode does not depend on reading the game's NVG mode back
addUserActionEventHandler ["nightVision", "Activate", { call FUNC(onNvKey) }];

// Mask calibration keybinds (Ctrl+Alt+Numpad by default), repeat while held
private _category = localize LSTRING(kb_category);
{
    _x params ["_action", "_key"];
    [
        _category,
        QGVAR(calib_) + _action,
        localize format ["STR_azeroot_ronim_main_kb_%1", _action],
        compile format ["['%1'] call %2", _action, QFUNC(calibrate)],
        {},
        [_key, [false, true, true]],
        _action != "reset"
    ] call CBA_fnc_addKeybind;
} forEach [
    ["scaleUp", 78], ["scaleDown", 74], ["up", 72], ["down", 80],
    ["left", 75], ["right", 77], ["wider", 73], ["narrower", 71], ["reset", 76]
];

// Screen metrics for diagnosing tube proportions from the RPT
diag_log text format ["[RONIM] screen: resolution %1, safeZone %2, pixel %3, square width factor %4",
    getResolution, [safeZoneX, safeZoneY, safeZoneW, safeZoneH], [pixelW, pixelH], pixelW / pixelH];

[FUNC(tick), 0] call CBA_fnc_addPerFrameHandler;
