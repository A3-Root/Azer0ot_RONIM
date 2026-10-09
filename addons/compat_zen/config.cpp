#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "RONIM - Zeus Enhanced Modules";
        units[] = {
            "RONIM_Zeus_Settings",
            "RONIM_Zeus_Features",
            "RONIM_Zeus_Exempt",
            "RONIM_Zeus_BreakMount",
            "RONIM_Zeus_Reseat",
            "RONIM_Zeus_Optics"
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"azeroot_ronim_main", "azeroot_ronim_modules", "zen_custom_modules", "zen_dialog", "zen_modules", "A3_Modules_F_Curator"};
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

#define ZEUS_MODULE(cls,fnc,name) \
    class cls: zen_modules_moduleBase { \
        author = "Root, Azer0"; \
        _generalMacro = QUOTE(cls); \
        category = "RONIM"; \
        function = QFUNC(fnc); \
        displayName = name; \
        curatorCanAttach = 1; \
    }

class CfgVehicles {
    class zen_modules_moduleBase;
    ZEUS_MODULE(RONIM_Zeus_Settings,zeusSettings,ECSTRING(main,zeus_settings));
    ZEUS_MODULE(RONIM_Zeus_Features,zeusFeatures,ECSTRING(main,zeus_features));
    ZEUS_MODULE(RONIM_Zeus_Exempt,zeusExempt,ECSTRING(main,zeus_exempt));
    ZEUS_MODULE(RONIM_Zeus_BreakMount,zeusBreakMount,ECSTRING(main,zeus_breakMount));
    ZEUS_MODULE(RONIM_Zeus_Reseat,zeusReseat,ECSTRING(main,zeus_reseat));
    ZEUS_MODULE(RONIM_Zeus_Optics,zeusOptics,ECSTRING(main,zeus_optics));
};
