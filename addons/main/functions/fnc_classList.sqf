#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * A comma separated classname setting as a lowercase array (parsed once per distinct value).
 *
 * Arguments:
 * 0: Setting name without prefix <STRING>
 *
 * Return Value:
 * Lowercase classnames <ARRAY>
 *
 * Public: No
 */

params [["_name", "", [""]]];

private _raw = [_name] call FUNC(settingValue);
if (isNil "_raw" || {!(_raw isEqualType "")}) exitWith { [] };

GVAR(cacheList) getOrDefaultCall [_raw, {
    (_raw splitString ", ;") apply { toLowerANSI _x }
}, true]
