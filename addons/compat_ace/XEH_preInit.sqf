#include "script_component.hpp"

// ACE's sway loop rewrites setCustomAimCoef every 0.5 s, so the ADS multiplier goes in as a factor
if (!isNil "ace_common_fnc_addSwayFactor") then {
    MVAR(aceSway) = true;
};
