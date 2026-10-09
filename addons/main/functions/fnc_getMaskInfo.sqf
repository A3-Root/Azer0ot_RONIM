#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Tube mask texture for an NVG, read from its config at runtime.
 * "optic": the NVG's own optic overlay. RONIM's NVG compat addons blank modelOptics (so the engine
 *          stops drawing it) and keep its texture and textured quad (azeroot_ronim_maskTexture,
 *          azeroot_ronim_opticQuad[] = {halfW, halfH, centreX, centreY} in model units). Without
 *          compat the texture is looked up by name next to modelOptics.
 * "ace":   the NVG's ace_nightvision_border texture, laid out with ACE's own geometry.
 * "ronim": RONIM's generated mask for the tube type (always used for monoculars by default).
 *
 * Arguments:
 * 0: HMD class <STRING>
 * 1: Tube type <NUMBER>
 *
 * Return Value:
 * [texture, kind, texture width / height, optic quad or []] <ARRAY>
 *
 * Public: No
 */

params [["_hmd", "", [""]], ["_tube", TUBE_BINO, [0]]];

private _source = MSET(maskSource);
private _monoCustom = _tube == TUBE_MONO && {MSET(monoCustomMask)};
private _shape = TUBE_SHAPES select MSET(tubeShape);

GVAR(cacheMask) getOrDefaultCall [format ["%1|%2|%3|%4|%5", toLowerANSI _hmd, _source, _tube, _monoCustom, _shape], {
    private _cfg = configFile >> "CfgWeapons" >> _hmd;
    private _texture = "";
    private _kind = "ronim";
    private _quad = [];

    // ACE already replaces the base game's overlay with its border; keep ACE's look for those
    private _stored = getText (_cfg >> "azeroot_ronim_maskTexture");
    private _aceOwned = GVAR(aceNvg)
        && {toLowerANSI (_stored select [0, 4]) == "\a3\"}
        && {getText (_cfg >> "ace_nightvision_border") != ""};

    if (!_monoCustom && {!_aceOwned} && {_source in [0, 1]}) then {
        _texture = _stored;
        if (_texture != "" && {fileExists _texture}) then {
            _kind = "optic";
            _quad = getArray (_cfg >> "azeroot_ronim_opticQuad");
            if !(count _quad == 4 && {_quad isEqualTypeAll 0}) then { _quad = []; };
        } else {
            _texture = "";
            private _model = getText (_cfg >> "azeroot_ronim_modelOptics");
            if (_model == "") then { _model = getText (_cfg >> "modelOptics"); };
            if (_model select [0, 1] == "\") then { _model = _model select [1]; };
            if (count _model > 4 && {toLowerANSI (_model select [count _model - 4]) == ".p3d"}) then { _model = _model select [0, count _model - 4]; };
            if (_model != "") then {
                {
                    private _candidate = _model + _x;
                    if (fileExists _candidate) exitWith { _texture = "\" + _candidate; _kind = "optic"; };
                } forEach ["_ca.paa", "_ca2.paa", "_co.paa", ".paa"];
            };
        };
    };

    if (_kind == "ronim" && {!_monoCustom} && {_source in [0, 2]}) then {
        private _border = getText (_cfg >> "ace_nightvision_border");
        if (_border != "") then { _texture = _border; _kind = "ace"; };
    };

    if (_kind == "ronim") then {
        _texture = format ["%1mask_%2_%3_ca.paa", TEX_ROOT, TUBE_NAMES select (_tube max 1), _shape];
    };

    private _info = getTextureInfo _texture;
    private _aspect = 1;
    if (_info isNotEqualTo [] && {(_info select 1) > 0}) then { _aspect = (_info select 0) / (_info select 1); };

    RLOG_3("mask for %1: %2 (%3)",_hmd,_texture,_kind);
    [_texture, _kind, _aspect, _quad]
}, true]
