#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Current effective value of a RONIM setting (runtime override, else CBA setting).
 *
 * Arguments:
 * 0: Setting name without prefix <STRING>
 *
 * Return Value:
 * Value <ANY>
 *
 * Public: No
 */

params [["_name", "", [""]]];

missionNamespace getVariable ["azeroot_ronim_main_ov_" + _name, missionNamespace getVariable ("azeroot_ronim_main_" + _name)]
