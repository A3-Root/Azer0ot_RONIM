#include "..\script_component.hpp"
/*
 * Author: Root, Azer0
 * Relative power of a round, used to scale kicks and chances: CfgAmmo hit / 10, clamped 0.3-3.
 * Roughly 5.56 = 0.8, 7.62 = 1.2, .338 = 1.6, .50 BMG = 3.
 *
 * Arguments:
 * 0: Ammo class <STRING>
 *
 * Return Value:
 * Factor <NUMBER>
 *
 * Public: No
 */

params [["_ammo", "", [""]]];

GVAR(cacheRecoil) getOrDefaultCall [_ammo, {
    ((getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit")) / 10) max 0.3 min 3
}, true]
