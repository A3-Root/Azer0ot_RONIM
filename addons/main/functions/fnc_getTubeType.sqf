#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Tube layout of an NVG / HMD class.
 * Order: ignore list, API (setTubeType), mono/bino/quad lists, then auto-detection:
 * config property azeroot_ronim_tubeType ("mono"/"bino"/"quad"/"none" or 0-3), the ACE border
 * texture, then keywords in class, display name and model. Default binocular.
 *
 * Arguments:
 * 0: HMD class <STRING>
 *
 * Return Value:
 * TUBE_NONE / TUBE_MONO / TUBE_BINO / TUBE_QUAD <NUMBER>
 *
 * Public: No
 */

params [["_hmd", "", [""]]];

if (_hmd == "") exitWith { TUBE_NONE };
private _class = toLowerANSI _hmd;

if (_class in (["nvgIgnore"] call FUNC(classList))) exitWith { TUBE_NONE };

private _apiIndex = GVAR(apiTubeTypes) findIf { (_x select 0) == _class };
if (_apiIndex != -1) exitWith { (GVAR(apiTubeTypes) select _apiIndex) select 1 };

if (_class in (["nvgMono"] call FUNC(classList))) exitWith { TUBE_MONO };
if (_class in (["nvgBino"] call FUNC(classList))) exitWith { TUBE_BINO };
if (_class in (["nvgQuad"] call FUNC(classList))) exitWith { TUBE_QUAD };

GVAR(cacheTube) getOrDefaultCall [_class, {
    private _cfg = configFile >> "CfgWeapons" >> _hmd;
    private _prop = _cfg >> "azeroot_ronim_tubeType";
    private _type = -1;

    if (isNumber _prop) then { _type = (round getNumber _prop) max 0 min 3; };
    if (isText _prop) then { _type = TUBE_NAMES find toLowerANSI getText _prop; };

    if (_type == -1) then {
        private _border = toLowerANSI getText (_cfg >> "ace_nightvision_border");
        if (_border find "quad" != -1) then { _type = TUBE_QUAD; };
        if (_type == -1 && {_border find "binos" != -1}) then { _type = TUBE_BINO; };
    };

    if (_type == -1) then {
        private _text = toLowerANSI format ["%1 %2 %3", _hmd, getText (_cfg >> "displayName"), getText (_cfg >> "model")];
        private _has = { params ["_words"]; (_words findIf { _text find _x != -1 }) != -1 };
        _type = switch (true) do {
            case ([["gpnvg", "quad", "panoramic", "pano"]] call _has): { TUBE_QUAD };
            case ([["pvs14", "pvs-14", "pvs_14", "pvs 14", "pvs18", "pvs-18", "pvs_18", "mono"]] call _has): { TUBE_MONO };
            default { TUBE_BINO };
        };
    };
    _type
}, true]
