#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Forces the tube layout of an NVG class for this mission, ahead of the CBA lists and
 * auto-detection. "auto" (or "") removes the entry. "none" makes RONIM ignore the NVG.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: NVG class <STRING>
 * 1: Type: "mono", "bino", "quad", "none", "auto" <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["NVGoggles_OPFOR", "mono"] call azeroot_ronim_fnc_setTubeType
 *
 * Public: Yes
 */

params [["_class", "", [""]], ["_type", "auto", [""]]];

if (!isServer) exitWith { [QGVAR(api), ["setTubeType", _this]] call CBA_fnc_serverEvent; };
if (_class == "") exitWith {};

_class = toLowerANSI _class;
private _index = TUBE_NAMES find toLowerANSI _type;
private _list = GVAR(apiTubeTypes) select { (_x select 0) != _class };
if (_index != -1) then { _list pushBack [_class, _index]; };

missionNamespace setVariable [QGVAR(apiTubeTypes), _list, true];
