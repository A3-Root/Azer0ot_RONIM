#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Zeus (placed on a unit): toggles the unit's exemption from RONIM.
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

private _exempt = !(_unit getVariable [QMVAR(exempt), false]);
[_unit, _exempt] call API(setUnitExempt);
[[LELSTRING(main,msgExemptOff), LELSTRING(main,msgExemptOn)] select _exempt] call zen_common_fnc_showMessage;
