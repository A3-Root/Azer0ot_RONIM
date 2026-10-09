#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Per-frame client loop.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _dt = diag_deltaTime min 0.1;

if (MSET(enabled)) then {
    call FUNC(updateState);
} else {
    GVAR(nvgOn) = false;
    GVAR(ads) = false;
    GVAR(optActive) = false;
    GVAR(pipActive) = false;
    GVAR(nvRequested) = false;
    GVAR(engineOurs) = false;
};

call FUNC(pipUpdate);
[_dt] call FUNC(swayStep);

if (GVAR(flashLevel) > 0) then {
    GVAR(flashLevel) = (GVAR(flashLevel) - _dt / (MSET(flashDuration) max 0.05)) max 0;
};

call FUNC(maskUpdate);

// Weapon sway while aiming with NVGs; compat_ace routes this through ACE sway factors instead
if (!GVAR(aceSway)) then {
    private _coef = [1, MSET(adsAimMult)] select GVAR(optActive);
    if (_coef != 1) then {
        GVAR(unit) setCustomAimCoef _coef;
        GVAR(aimCoefSet) = true;
    } else {
        if (GVAR(aimCoefSet)) then {
            GVAR(unit) setCustomAimCoef 1;
            GVAR(aimCoefSet) = false;
        };
    };
};

if (GVAR(calibSaveAt) > 0 && {diag_tickTime > GVAR(calibSaveAt)}) then {
    GVAR(calibSaveAt) = 0;
    saveProfileNamespace;
};

if (GVAR(debugOverlay) && {diag_tickTime > GVAR(debugNext)}) then {
    GVAR(debugNext) = diag_tickTime + 0.25;
    call FUNC(debugOverlay);
};
