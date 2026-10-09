#include "script_component.hpp"

if (!hasInterface) exitWith {};

if (MVAR(aceSway)) then {
    ["multiplier", {
        [1, MSET(adsAimMult)] select (missionNamespace getVariable [QMVAR(optActive), false])
    }, QGVAR(adsAim)] call ace_common_fnc_addSwayFactor;
};

// Self-interaction > Equipment > Re-seat NVG mount, while the mount is misaligned
private _action = [
    QGVAR(reseat),
    LELSTRING(main,reseat),
    "",
    {
        params ["", "_player"];
        [
            MSET(reseatTime),
            [_player],
            {
                (_this select 0) params ["_unit"];
                [_unit] call API(reseatMount);
                hintSilent LELSTRING(main,reseated);
            },
            {},
            LELSTRING(main,reseating),
            { hmd ((_this select 0) select 0) != "" }
        ] call ace_common_fnc_progressBar;
    },
    {
        params ["", "_player"];
        MSET(reseatAction)
            && {hmd _player != ""}
            && {vectorMagnitude (missionNamespace getVariable [QMVAR(misalign), [0, 0, 0]]) > 0.0005}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;
