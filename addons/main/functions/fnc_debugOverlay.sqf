#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * On-screen state of the local player (debugOverlay setting).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

hintSilent format [
    "RONIM\nhmd: %1 (%2)\nnvg: %3  pip: %12  ads: %4\nzoom: %5  magnified: %6\nintegrated: %7  optic features: %8\nsway: %9\nmisalign: %10\nflash: %11",
    GVAR(hmd),
    TUBE_NAMES select GVAR(tube),
    GVAR(nvgOn),
    GVAR(ads),
    GVAR(zoom) toFixed 2,
    GVAR(magnified),
    GVAR(integrated),
    GVAR(optActive),
    (GVAR(swayPos) select [0, 2]) apply { _x toFixed 3 },
    (vectorMagnitude GVAR(misalign)) toFixed 3,
    GVAR(flashLevel) toFixed 2,
    GVAR(pipActive)
];
