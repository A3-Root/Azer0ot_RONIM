#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Mask size and position for an NVG: [scale, offsetX, offsetY, stretch].
 * scale = mask height in screen heights ("ace": multiplier on ACE's geometry), offsets in screen
 * fractions, stretch = width multiplier.
 * Order: this player's calibration (keybinds, saved in the profile), Classes > Mask calibration,
 * config property azeroot_ronim_mask[] = {scale, offsetX, offsetY, stretch}, default per kind.
 *
 * Arguments:
 * 0: HMD class <STRING>
 * 1: Mask kind ("optic", "ace", "ronim") <STRING>
 *
 * Return Value:
 * [scale, offsetX, offsetY, stretch] <ARRAY>
 *
 * Public: No
 */

params [["_hmd", "", [""]], ["_kind", "ronim", [""]]];

private _class = toLowerANSI _hmd;

private _personal = GVAR(calibProfile) get _class;
if (!isNil "_personal") exitWith { _personal };

private _raw = MSET(maskCalibration);
private _list = GVAR(cacheList) getOrDefaultCall ["calib|" + _raw, {
    private _map = createHashMap;
    {
        private _parts = _x splitString ":";
        if (count _parts == 5) then {
            _map set [toLowerANSI (_parts select 0), (_parts select [1, 4]) apply { parseNumber _x }];
        };
    } forEach (_raw splitString ", ;");
    _map
}, true];
private _server = _list get _class;
if (!isNil "_server") exitWith { _server };

private _prop = getArray (configFile >> "CfgWeapons" >> _hmd >> "azeroot_ronim_mask");
if (count _prop == 4 && {_prop isEqualTypeAll 0}) exitWith { _prop };

if (_kind != "optic") exitWith { [1, 0, 0, 1] };

// Optic overlay with known model geometry: size and place it from the textured quad
([_hmd, GVAR(tube)] call FUNC(getMaskInfo)) params ["", "", "_texAspect", "_quad"];
if (_quad isEqualTo []) exitWith { [2.2, 0, 0, 1] };
_quad params ["_halfW", "_halfH", "_centreX", "_centreY"];
private _modelScale = MSET(opticModelScale);
[
    2 * _halfH * _modelScale,
    _centreX * _modelScale / (getResolution select 4),
    -_centreY * _modelScale,
    (_halfW / (_halfH max 1e-6)) / (_texAspect max 1e-6)
]
