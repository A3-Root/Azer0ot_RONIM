#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "RONIM - 3DEN Modules";
        units[] = {"RONIM_Module_Settings", "RONIM_Module_Exempt"};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"azeroot_ronim_main", "A3_Modules_F", "3DEN"};
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

#include "CfgFactionClasses.hpp"
#include "CfgVehicles.hpp"
#include "Cfg3DEN.hpp"
