#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Opens or closes the NVG overlay display.
 *
 * Arguments:
 * 0: Show <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_show"];

if (_show) then {
    GVAR(displayOverHud) = MSET(maskOverHud);
    QGVAR(layer) cutRsc [QGVAR(display), "PLAIN", 0, false, GVAR(displayOverHud)];
} else {
    QGVAR(layer) cutText ["", "PLAIN"];
    if (GVAR(ppFlash) != -1) then {
        ppEffectDestroy GVAR(ppFlash);
        GVAR(ppFlash) = -1;
    };
};
GVAR(displayShown) = _show;
