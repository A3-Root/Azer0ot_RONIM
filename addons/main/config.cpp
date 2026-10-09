#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "RONIM - Main";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main", "cba_settings", "cba_xeh", "cba_events", "cba_common", "cba_ui"};
        author = "Root, Azer0";
        authors[] = {"Root", "Azer0"};
        url = "https://github.com/A3-Root/Azer0ot_RONIM";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "RscTitles.hpp"
