#include "script_component.hpp"

// Unit-targeted requests (API/Zeus from another machine): run where the unit is local
[QGVAR(breakMount), { params ["_unit"]; if (local _unit) then { [_unit] call API(breakMount); }; }] call CBA_fnc_addEventHandler;
[QGVAR(reseatMount), { params ["_unit"]; if (local _unit) then { [_unit] call API(reseatMount); }; }] call CBA_fnc_addEventHandler;

// Server is the authority for shared mission state (overrides, optic and tube lists)
if (isServer) then {
    [QGVAR(api), {
        params ["_fnc", "_args"];
        if !(_fnc in ["setOverride", "clearOverrides", "addIntegratedOptics", "removeIntegratedOptics", "setTubeType"]) exitWith {};
        _args call (missionNamespace getVariable [format ["azeroot_ronim_fnc_%1", _fnc], {}]);
    }] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
    call FUNC(initPlayer);
};
