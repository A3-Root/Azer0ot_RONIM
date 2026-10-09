#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Lays out the NVG overlay for this frame: tube mask at its sway offset with black fillers
 * around it, muzzle flash bloom, monocular reticle copy. Hides ACE's static tube mask when the
 * RONIM mask replaces it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// Aiming through an integrated NV optic shows the optic's own picture, no tube in front of it
private _show = GVAR(nvgOn) && {!(GVAR(ads) && GVAR(integrated))};
if (!_show) exitWith {
    if (GVAR(displayShown)) then { [false] call FUNC(maskShow); };
};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) then {
    [true] call FUNC(maskShow);
    _display = uiNamespace getVariable [QGVAR(display), displayNull];
};
if (isNull _display) exitWith {};

private _aspect = getResolution select 4;
private _unitX = (safeZoneW / safeZoneH) / _aspect; // UI width per UI height for square pixels
private _cx = safeZoneX + safeZoneW / 2;
private _cy = safeZoneY + safeZoneH / 2;

// ------------------------------------------------------------------ tube mask
private _aceMode = [0, MSET(aceMaskMode)] select GVAR(aceNvg);
private _drawMask = MSET(maskEnabled) && _aceMode != 1;
private _maskCtrls = [IDC_MASK, IDC_FILL_TOP, IDC_FILL_BOTTOM, IDC_FILL_LEFT, IDC_FILL_RIGHT] apply { _display displayCtrl _x };

if (_drawMask) then {
    _maskCtrls params ["_mask", "_top", "_bottom", "_left", "_right"];
    private _tex = format ["%1mask_%2_ca.paa", TEX_ROOT, TUBE_NAMES select GVAR(tube)];
    if (ctrlText _mask != _tex) then { _mask ctrlSetText _tex; };

    private _h = safeZoneH * MSET(maskScale);
    private _w = 2 * _h * _unitX;
    private _pos = GVAR(swayPos);
    private _mx = _cx + (_pos select 0) * safeZoneH * _unitX;
    private _my = _cy + (_pos select 1) * safeZoneH;
    if (GVAR(tube) == TUBE_MONO) then {
        _mx = _mx + ([-1, 1] select (MSET(monoSide) == 1)) * MSET(monoShift) * safeZoneW;
    };
    private _x0 = _mx - _w / 2;
    private _y0 = _my - _h / 2;
    private _big = 4;

    _mask ctrlSetPosition [_x0, _y0, _w, _h];
    _top ctrlSetPosition [safeZoneXAbs - _big, _y0 - _big, safeZoneWAbs + 2 * _big, _big + 0.001];
    _bottom ctrlSetPosition [safeZoneXAbs - _big, _y0 + _h - 0.001, safeZoneWAbs + 2 * _big, _big];
    _left ctrlSetPosition [_x0 - _big, _y0, _big + 0.001, _h];
    _right ctrlSetPosition [_x0 + _w - 0.001, _y0, _big, _h];

    private _fade = 1 - MSET(maskOpacity);
    {
        _x ctrlShow true;
        _x ctrlSetFade _fade;
        _x ctrlCommit 0;
    } forEach _maskCtrls;
} else {
    { _x ctrlShow false; } forEach _maskCtrls;
};

// ACE draws its own fixed mask (controls 1001-1003); hide it when RONIM's replaces it
if (_aceMode == 0 && _drawMask) then {
    private _ace = uiNamespace getVariable ["ace_nightvision_titleDisplay", displayNull];
    if (!isNull _ace) then {
        {
            private _ctrl = _ace displayCtrl _x;
            if (ctrlShown _ctrl) then { _ctrl ctrlShow false; };
        } forEach [1001, 1002, 1003];
    };
};

// ------------------------------------------------------------------ muzzle flash bloom
private _flash = _display displayCtrl IDC_FLASH;
private _level = GVAR(flashLevel);
_flash ctrlSetBackgroundColor [0.88, 1, 0.88, _level ^ 0.8];

if (_level > 0) then {
    if (GVAR(ppFlash) == -1) then {
        private _priority = 1560;
        while {
            GVAR(ppFlash) = ppEffectCreate ["ColorCorrections", _priority];
            GVAR(ppFlash) == -1 && _priority < 1600
        } do {
            _priority = _priority + 1;
        };
        if (GVAR(ppFlash) != -1) then {
            GVAR(ppFlash) ppEffectForceInNVG true;
            GVAR(ppFlash) ppEffectEnable true;
        };
    };
    if (GVAR(ppFlash) != -1) then {
        GVAR(ppFlash) ppEffectAdjust [1 + _level * 2.5, 1 - _level * 0.5, _level * 0.25, [1, 1, 1, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]];
        GVAR(ppFlash) ppEffectCommit 0;
    };
} else {
    if (GVAR(ppFlash) != -1) then {
        ppEffectDestroy GVAR(ppFlash);
        GVAR(ppFlash) = -1;
    };
};

// ------------------------------------------------------------------ monocular reticle copy
private _reticle = _display displayCtrl IDC_RETICLE;
if (MSET(reticleEnabled) && GVAR(optActive) && GVAR(tube) == TUBE_MONO) then {
    private _style = [GVAR(unit)] call FUNC(getReticleStyle);
    private _tex = format ["%1reticle_%2_ca.paa", TEX_ROOT, RETICLE_STYLES select _style];
    if (ctrlText _reticle != _tex) then { _reticle ctrlSetText _tex; };

    private _h = MSET(reticleSize) * safeZoneH;
    private _w = _h * _unitX;
    private _side = [1, -1] select (MSET(monoSide) == 1);
    private _rx = _cx + _side * MSET(reticleOffset) * safeZoneW;
    private _color = +([[1, 0.15, 0.1], [0.25, 1, 0.25], [1, 0.7, 0.1], [0, 0, 0]] select MSET(reticleColor));
    _color pushBack MSET(reticleOpacity);

    _reticle ctrlSetTextColor _color;
    _reticle ctrlSetPosition [_rx - _w / 2, _cy - _h / 2, _w, _h];
    _reticle ctrlShow true;
    _reticle ctrlCommit 0;
} else {
    _reticle ctrlShow false;
};
