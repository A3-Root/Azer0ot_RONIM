#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus (placed on a unit): re-seats the unit's NVG mount, clearing misalignment.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if (!hasInterface) exitWith {};
private _unit = attachedTo _logic;
deleteVehicle _logic;

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith { [LELSTRING(main,msgNeedUnit)] call zen_common_fnc_showMessage; };

[_unit] call API(reseatMount);
[LELSTRING(main,msgReseated)] call zen_common_fnc_showMessage;
