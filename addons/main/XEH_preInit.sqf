#include "script_component.hpp"
ADDON = false;

#include "XEH_PREP.hpp"
#include "initSettings.inc.sqf"

// Hooks compat addons may replace (their preInit runs after this one)
// Bruise: params ["_unit", "_damage"]. Vanilla fallback keeps head damage well below lethal.
GVAR(bruiseFnc) = {
    params ["_unit", "_damage"];
    _unit setHitPointDamage ["HitHead", ((_unit getHitPointDamage "HitHead") + _damage) min 0.5];
};
// Set by compat_ace: weapon sway goes through ACE sway factors instead of setCustomAimCoef
GVAR(aceSway) = false;
GVAR(aceNvg) = isClass (configFile >> "CfgPatches" >> "ace_nightvision");

// Per-class lookups (config reads and parsed setting lists)
GVAR(cacheList) = createHashMap;
GVAR(cacheIntegrated) = createHashMap;
GVAR(cacheTube) = createHashMap;
GVAR(cacheSupp) = createHashMap;
GVAR(cacheRecoil) = createHashMap;
GVAR(cacheReticle) = createHashMap;

// Mission state shared through the server (API)
if (isNil QGVAR(apiIntegrated)) then { GVAR(apiIntegrated) = []; };
if (isNil QGVAR(apiTubeTypes)) then { GVAR(apiTubeTypes) = []; };

ADDON = true;
