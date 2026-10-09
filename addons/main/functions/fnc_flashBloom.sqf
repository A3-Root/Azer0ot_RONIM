#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Starts or tops up the muzzle flash bloom. A shot while the previous bloom still fades only adds
 * the follow-up share, so automatic fire stays bright without pinning at full white.
 *
 * Arguments:
 * 0: Scale, 1 = own unsuppressed shot <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_scale", 1, [0]]];

private _add = MSET(flashIntensity) * _scale;
private _level = GVAR(flashLevel);

GVAR(flashLevel) = if (_level > 0.05) then {
    ((_level + _add * MSET(flashStack)) min (_add max _level)) min 1
} else {
    (_level max _add) min 1
};

[QGVAR(flash), [GVAR(flashLevel)]] call CBA_fnc_localEvent;
