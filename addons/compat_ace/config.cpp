#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "RONIM - ACE Compatibility";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"azeroot_ronim_main", "ace_common", "ace_interact_menu"};
        skipWhenMissingDependencies = 1;
        author = "Root, Azer0";
        authors[] = {"Root", "Azer0"};
        url = "https://github.com/A3-Root/Azer0ot_RONIM";
        VERSION_CONFIG;
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};
