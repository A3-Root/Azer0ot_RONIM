#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Calibration keybinds: nudges the current NVG's mask size/position, saves it to this player's
 * profile and shows the Classes > Mask calibration entry for sharing.
 *
 * Arguments:
 * 0: Action: "scaleUp", "scaleDown", "up", "down", "left", "right", "wider", "narrower", "reset" <STRING>
 *
 * Return Value:
 * Handled <BOOL>
 *
 * Public: No
 */

params [["_action", "", [""]]];

private _hmd = GVAR(hmd);
if (_hmd == "" || {!GVAR(nvgOn)}) exitWith { false };

private _class = toLowerANSI _hmd;
private _kind = ([_hmd, GVAR(tube)] call FUNC(getMaskInfo)) select 1;

if (_action == "reset") then {
    GVAR(calibProfile) deleteAt _class;
} else {
    ([_hmd, _kind] call FUNC(getCalibration)) params ["_scale", "_x0", "_y0", "_stretch"];
    switch (_action) do {
        case "scaleUp": { _scale = _scale * 1.004; };
        case "scaleDown": { _scale = _scale / 1.004; };
        case "up": { _y0 = _y0 - 0.001; };
        case "down": { _y0 = _y0 + 0.001; };
        case "left": { _x0 = _x0 - 0.001; };
        case "right": { _x0 = _x0 + 0.001; };
        case "wider": { _stretch = _stretch * 1.003; };
        case "narrower": { _stretch = _stretch / 1.003; };
    };
    GVAR(calibProfile) set [_class, [_scale, _x0, _y0, _stretch]];
};

// Saved to disk by fnc_tick once the keys are released (held keys repeat every frame)
private _pairs = [];
{ _pairs pushBack [_x, _y]; } forEach GVAR(calibProfile);
profileNamespace setVariable [QGVAR(calibration), _pairs];
GVAR(calibSaveAt) = diag_tickTime + 1;

private _values = [_hmd, _kind] call FUNC(getCalibration);
private _text = format ["%1\n%2:%3", localize LSTRING(calibHint), _hmd, (_values apply { _x toFixed 3 }) joinString ":"];
// With model geometry, one global value sizes every NVG overlay: show it for Optic overlay scale
private _quad = ([_hmd, GVAR(tube)] call FUNC(getMaskInfo)) select 3;
if (_quad isNotEqualTo []) then {
    _text = _text + format ["\n%1: %2", localize LSTRING(opticModelScale), ((_values select 0) / (2 * (_quad select 1))) toFixed 2];
};
hintSilent _text;
true
