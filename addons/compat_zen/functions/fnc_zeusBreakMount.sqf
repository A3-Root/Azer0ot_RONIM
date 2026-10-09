#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus (placed on a unit): breaks the unit's NVG mount, the goggles drop to the ground.
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
if (hmd _unit == "") exitWith { [LELSTRING(main,msgNoNvg)] call zen_common_fnc_showMessage; };

[_unit] call API(breakMount);
[LELSTRING(main,msgBroken)] call zen_common_fnc_showMessage;
