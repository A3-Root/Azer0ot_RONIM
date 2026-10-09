#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * RONIM state of a unit. Live NVG/aiming values are only known on the machine of the player
 * controlling the unit; elsewhere only exempt, hmd and tube are filled.
 *
 * Arguments:
 * 0: Unit <OBJECT> (default: player)
 *
 * Return Value:
 * State <HASHMAP>: exempt, hmd, tube ("none"/"mono"/"bino"/"quad"), live, and when live:
 * nvgOn, ads, zoom, magnified, integrated, opticFeatures, misalign, flash, sway ([x, y])
 *
 * Example:
 * ([player] call azeroot_ronim_fnc_getState) get "opticFeatures"
 *
 * Public: Yes
 */

params [["_unit", player, [objNull]]];

private _hmd = hmd _unit;
private _state = createHashMapFromArray [
    ["exempt", _unit getVariable [QGVAR(exempt), false]],
    ["hmd", _hmd],
    ["tube", TUBE_NAMES select ([_hmd] call FUNC(getTubeType))],
    ["live", false]
];

if (hasInterface && {_unit isEqualTo (missionNamespace getVariable [QGVAR(unit), objNull])}) then {
    _state set ["live", true];
    _state set ["nvgOn", GVAR(nvgOn)];
    _state set ["ads", GVAR(ads)];
    _state set ["zoom", GVAR(zoom)];
    _state set ["magnified", GVAR(magnified)];
    _state set ["integrated", GVAR(integrated)];
    _state set ["opticFeatures", GVAR(optActive)];
    _state set ["misalign", vectorMagnitude GVAR(misalign)];
    _state set ["flash", GVAR(flashLevel)];
    _state set ["sway", GVAR(swayPos) select [0, 2]];
};

_state
