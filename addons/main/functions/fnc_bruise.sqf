#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Recoil drives the NVG into the face: chance-based head bruise with a cooldown.
 * ACE medical (compat_ace) gives a contusion, vanilla adds a little head damage.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Recoil factor <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_rf"];

if (time < GVAR(bruiseNext)) exitWith {};

private _scaled = MSET(bruiseRecoilScale);
if (random 1 >= MSET(bruiseChance) * ([1, _rf] select _scaled)) exitWith {};

GVAR(bruiseNext) = time + MSET(bruiseCooldown);
private _damage = (MSET(bruiseDamage) * ([1, sqrt _rf] select _scaled)) min 0.34;

[_unit, _damage] call GVAR(bruiseFnc);
[QGVAR(bruised), [_unit, _damage]] call CBA_fnc_localEvent;
RLOG_1("bruise, damage %1",_damage);
