#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Lays out the NVG overlay for this frame.
 * Tube group = the tube's box on screen (shifted by sway). Inside it: the PiP night vision picture
 * (screen sized, shifted only by sway, so the picture moves against the real aim point), the
 * flash bloom and the mask texture. Black fillers cover the rest of the screen, except for a
 * monocular in PiP mode, where the other eye keeps the real view.
 * Game NVG mode: no PiP picture; the mask covers the game's full screen night vision, and ACE's
 * static mask is hidden when RONIM's replaces it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// First person only; aiming through an integrated NV optic shows the optic's own picture
private _show = GVAR(nvgOn) && GVAR(firstPerson) && {!(GVAR(ads) && GVAR(integrated))};
if (!_show) exitWith {
    if (GVAR(displayShown)) then { [false] call FUNC(maskShow); };
};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
// Reopen when the layer changes between under and over the HUD
if (!isNull _display && {GVAR(displayOverHud) isNotEqualTo MSET(maskOverHud)}) then {
    [false] call FUNC(maskShow);
    _display = displayNull;
};
if (isNull _display) then {
    [true] call FUNC(maskShow);
    _display = uiNamespace getVariable [QGVAR(display), displayNull];
};
if (isNull _display) exitWith {};

private _pip = GVAR(pipActive);
private _tube = GVAR(tube);
private _mono = _tube == TUBE_MONO;
// UI width per UI height for square on-screen proportions, from the engine's own pixel size
private _unitX = pixelW / pixelH;
private _cx = safeZoneX + safeZoneW / 2;
private _cy = safeZoneY + safeZoneH / 2;
private _pos = GVAR(swayPos);
private _dx = (_pos select 0) * safeZoneH * _unitX;
private _dy = (_pos select 1) * safeZoneH;

private _group = _display displayCtrl IDC_GROUP;
private _picture = _group controlsGroupCtrl IDC_PIP;
private _flash = _group controlsGroupCtrl IDC_FLASH;
private _mask = _group controlsGroupCtrl IDC_MASK;
private _fillers = [IDC_FILL_TOP, IDC_FILL_BOTTOM, IDC_FILL_LEFT, IDC_FILL_RIGHT] apply { _display displayCtrl _x };

// ------------------------------------------------------------------ tube box
private _aceMode = [0, MSET(aceMaskMode)] select (GVAR(aceNvg) && !_pip);
private _drawMask = MSET(maskEnabled) && _aceMode != 1;
private _box = [safeZoneXAbs, safeZoneY, safeZoneWAbs, safeZoneH];

if (_drawMask) then {
    ([GVAR(hmd), _tube] call FUNC(getMaskInfo)) params ["_tex", "_kind", "_texAspect"];
    ([GVAR(hmd), _kind] call FUNC(getCalibration)) params ["_calScale", "_calX", "_calY", "_calStretch"];
    private _scale = _calScale * MSET(maskScale);
    private _h = safeZoneH * _scale;
    private _w = 0;
    switch (_kind) do {
        case "ace": {
            // ACE's own layout: 3 screen heights tall, 0.75 of that wide, growing with zoom
            private _screenY = (worldToScreen positionCameraToWorld [0, 1, 1]) param [1, 0.5];
            private _aceZoom = ((0.5 - _screenY) * (getResolution select 5) * 1.12513) max 0.1;
            _h = 3 * _h * _aceZoom;
            _w = 0.75 * _h * _calStretch;
        };
        case "optic": { _w = _h * _unitX * _texAspect * _calStretch; };
        default {
            private _shapeStretch = [1, MSET(shapeAspect)] select (MSET(tubeShape) in SHAPE_STRETCHED);
            _w = ([2, 1] select _mono) * _h * _unitX * _calStretch * _shapeStretch;
        };
    };
    private _mx = _cx + _dx + _calX * safeZoneW;
    if (_mono) then {
        _mx = _mx + ([-1, 1] select (MSET(monoSide) == 1)) * MSET(monoShift) * safeZoneW;
    };
    _box = [_mx - _w / 2, _cy + _dy + _calY * safeZoneH - _h / 2, _w, _h];

    if (ctrlText _mask != _tex) then { _mask ctrlSetText _tex; };
    _mask ctrlSetPosition [0, 0, _w, _h];
    _mask ctrlSetFade (1 - MSET(maskOpacity));
    _mask ctrlShow true;
    _mask ctrlCommit 0;
} else {
    _mask ctrlShow false;
};
_box params ["_x0", "_y0", "_w0", "_h0"];
_group ctrlSetPosition _box;
_group ctrlCommit 0;

// Other eye of a monocular: real view (PiP tube) or a PiP normal view (game NV tube) on the side
// without the tube, from the screen edge to the tube box. Its filler is left out.
private _otherEye = [0, MSET(monoOtherEye)] select (_drawMask && _mono);
if (_otherEye == 1 && !_pip) then { _otherEye = 0; };
if (_otherEye == 2 && !GVAR(eyePip)) then { _otherEye = [0, 1] select _pip; };
private _tubeRight = MSET(monoSide) == 1;

private _eyeGroup = _display displayCtrl IDC_EYE_GROUP;
private _eyePicture = _eyeGroup controlsGroupCtrl IDC_EYE_PIP;
if (_otherEye == 2) then {
    private _eyeBox = if (_tubeRight) then {
        [safeZoneXAbs, safeZoneY, (_x0 - safeZoneXAbs) max 0, safeZoneH]
    } else {
        [_x0 + _w0, safeZoneY, (safeZoneXAbs + safeZoneWAbs - _x0 - _w0) max 0, safeZoneH]
    };
    _eyeGroup ctrlSetPosition _eyeBox;
    _eyeGroup ctrlShow true;
    _eyeGroup ctrlCommit 0;
    private _tex = format ["#(argb,%1,%1,1)r2t(%2,1.0)", MSET(pipResolution), PIP_TARGET_EYE];
    if (ctrlText _eyePicture != _tex) then { _eyePicture ctrlSetText _tex; };
    // The naked eye does not sway with the goggles: screen aligned
    _eyePicture ctrlSetPosition [safeZoneX - (_eyeBox select 0), safeZoneY - (_eyeBox select 1), safeZoneW, safeZoneH];
    _eyePicture ctrlShow true;
    _eyePicture ctrlCommit 0;
} else {
    _eyeGroup ctrlShow false;
};

// Fillers: everything outside the box, except where the other eye sees the real or PiP view
if (_drawMask && _otherEye != 1) then {
    _fillers params ["_top", "_bottom", "_left", "_right"];
    private _big = 4;
    _top ctrlSetPosition [safeZoneXAbs - _big, _y0 - _big, safeZoneWAbs + 2 * _big, _big + 0.001];
    _bottom ctrlSetPosition [safeZoneXAbs - _big, _y0 + _h0 - 0.001, safeZoneWAbs + 2 * _big, _big];
    _left ctrlSetPosition [_x0 - _big, _y0, _big + 0.001, _h0];
    _right ctrlSetPosition [_x0 + _w0 - 0.001, _y0, _big, _h0];
    private _fade = 1 - MSET(maskOpacity);
    // Tube on the right leaves the left filler out (the eye picture is there), and vice versa
    private _skip = [objNull, [_right, _left] select _tubeRight] select (_otherEye == 2);
    // The other-eye picture spans the full height on its side, so the top/bottom fillers stop at it
    if (_otherEye == 2) then {
        // Tube on the right: from the tube box to the right edge; tube on the left: left edge to the box
        private _keepX = [safeZoneXAbs - _big, _x0] select _tubeRight;
        private _keepW = [_x0 + _w0 - safeZoneXAbs + _big, safeZoneXAbs + safeZoneWAbs + _big - _x0] select _tubeRight;
        _top ctrlSetPosition [_keepX, _y0 - _big, _keepW, _big + 0.001];
        _bottom ctrlSetPosition [_keepX, _y0 + _h0 - 0.001, _keepW, _big];
    };
    {
        if (_x isEqualTo _skip) then {
            _x ctrlShow false;
        } else {
            _x ctrlSetFade _fade;
            _x ctrlShow true;
            _x ctrlCommit 0;
        };
    } forEach _fillers;
} else {
    { _x ctrlShow false; } forEach _fillers;
};

// ------------------------------------------------------------------ PiP night vision picture
if (_pip) then {
    private _tex = format ["#(argb,%1,%1,1)r2t(%2,1.0)", MSET(pipResolution), PIP_TARGET];
    if (ctrlText _picture != _tex) then { _picture ctrlSetText _tex; };
    // Screen sized and world aligned, shifted by sway only (not by the monocular's eye offset)
    _picture ctrlSetPosition [safeZoneX + _dx - _x0, safeZoneY + _dy - _y0, safeZoneW, safeZoneH];
    _picture ctrlShow true;
    _picture ctrlCommit 0;
} else {
    _picture ctrlShow false;
};

// ACE draws its own fixed mask (controls 1001-1003) in game NVG mode; hide it when RONIM's replaces it
if (!_pip && _aceMode == 0 && _drawMask) then {
    private _ace = uiNamespace getVariable ["ace_nightvision_titleDisplay", displayNull];
    if (!isNull _ace) then {
        {
            private _ctrl = _ace displayCtrl _x;
            if (ctrlShown _ctrl) then { _ctrl ctrlShow false; };
        } forEach [1001, 1002, 1003];
    };
};

// ------------------------------------------------------------------ muzzle flash bloom
private _level = GVAR(flashLevel);
_flash ctrlSetPosition [0, 0, _w0, _h0];
_flash ctrlSetBackgroundColor [0.88, 1, 0.88, _level ^ 0.8];
_flash ctrlCommit 0;

// Game NVG mode also flares the 3D image itself; the PiP picture is not touched by post-process
if (_level > 0 && !_pip) then {
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

// ------------------------------------------------------------------ reticle
// PiP: the picture hides the scope, so the reticle sits on top at the aim point (screen centre).
// Game mode: the real reticle is visible; a monocular gets a copy on the side without the tube.
private _reticle = _display displayCtrl IDC_RETICLE;
private _side = 0;
private _drawReticle = MSET(reticleEnabled) && GVAR(optActive);
if (_drawReticle && !_pip) then {
    _drawReticle = _mono && {MSET(reticleSideCopy)};
    _side = ([1, -1] select (MSET(monoSide) == 1)) * MSET(reticleOffset) * safeZoneW;
};

if (_drawReticle) then {
    private _style = [GVAR(unit)] call FUNC(getReticleStyle);
    private _tex = format ["%1reticle_%2_ca.paa", TEX_ROOT, RETICLE_STYLES select _style];
    if (ctrlText _reticle != _tex) then { _reticle ctrlSetText _tex; };

    private _h = MSET(reticleSize) * safeZoneH;
    private _w = _h * _unitX;
    private _color = +([[1, 0.15, 0.1], [0.25, 1, 0.25], [1, 0.7, 0.1], [0, 0, 0]] select MSET(reticleColor));
    _color pushBack MSET(reticleOpacity);

    _reticle ctrlSetTextColor _color;
    _reticle ctrlSetPosition [_cx + _side - _w / 2, _cy - _h / 2, _w, _h];
    _reticle ctrlShow true;
    _reticle ctrlCommit 0;
} else {
    _reticle ctrlShow false;
};
