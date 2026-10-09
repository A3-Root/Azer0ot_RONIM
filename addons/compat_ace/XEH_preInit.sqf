#include "script_component.hpp"

// ACE's sway loop rewrites setCustomAimCoef every 0.5 s, so the ADS multiplier goes in as a factor
if (!isNil "ace_common_fnc_addSwayFactor") then {
    MVAR(aceSway) = true;
};

// ACE medical: a selection-specific punch below 0.35 damage gives a contusion (bruise)
if (!isNil "ace_medical_fnc_addDamageToUnit") then {
    MVAR(bruiseFnc) = {
        params ["_unit", "_damage"];
        [_unit, _damage, "Head", "punch", _unit] call ace_medical_fnc_addDamageToUnit;
    };
};
