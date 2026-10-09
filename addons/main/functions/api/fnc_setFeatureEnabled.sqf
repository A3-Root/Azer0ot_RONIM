#include "..\..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Switches one RONIM feature on or off for the whole mission (a setting override).
 * Features: "all", "pip", "mask", "sway", "adsSway", "misalign", "mount", "bruise", "flash", "reticle"
 * (or the setting name itself, e.g. "mountEnabled"). nil returns the feature to its CBA setting.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Feature <STRING>
 * 1: Enabled, nil = back to CBA setting <BOOL|NIL>
 *
 * Return Value:
 * Known feature <BOOL>
 *
 * Example:
 * ["mount", false] call azeroot_ronim_fnc_setFeatureEnabled
 * ["flash"] call azeroot_ronim_fnc_setFeatureEnabled
 *
 * Public: Yes
 */

params [["_feature", "", [""]], ["_enabled", nil, [true]]];

private _name = switch (toLowerANSI _feature) do {
    case "all";
    case "enabled": { "enabled" };
    case "pip": { "pipEnabled" };
    case "mask": { "maskEnabled" };
    case "sway": { "swayEnabled" };
    case "adssway": { "adsSwayEnabled" };
    case "misalign": { "misalignEnabled" };
    case "mount": { "mountEnabled" };
    case "bruise": { "bruiseEnabled" };
    case "flash": { "flashEnabled" };
    case "reticle": { "reticleEnabled" };
    default { _feature };
};

if ((GVAR(featureSettings) findIf { (_x select 0) == _name }) == -1) exitWith {
    diag_log text format ["[RONIM] Unknown feature: %1", _feature];
    false
};

[_name, _enabled] call API(setOverride);
true
