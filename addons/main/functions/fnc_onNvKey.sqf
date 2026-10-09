#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * NVG key pressed: in PiP mode this toggles RONIM's own night vision state (the game's NVG mode is
 * then kept in line by fnc_updateState).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

GVAR(lastNvKey) = diag_tickTime;
if (GVAR(pipMode)) then {
    GVAR(nvRequested) = !GVAR(nvRequested);
    RLOG_1("NVG key: PiP night vision %1",GVAR(nvRequested));
};
