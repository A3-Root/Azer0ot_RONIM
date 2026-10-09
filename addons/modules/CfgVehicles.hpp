// "Keep setting" = -1 for numbers and lists, "" for text: the CBA value stays untouched
#define ATTR_NUM(cls,label,tip) \
    class cls: Edit { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "NUMBER"; \
        defaultValue = -1; \
    }

#define ATTR_STR(cls,label,tip) \
    class cls: Edit { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "STRING"; \
        defaultValue = "''"; \
    }

#define ATTR_TRI(cls,label,tip) \
    class cls: Combo { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "NUMBER"; \
        defaultValue = -1; \
        class Values { \
            class Keep { name = ECSTRING(main,keep); value = -1; }; \
            class Off { name = ECSTRING(main,off); value = 0; }; \
            class On { name = ECSTRING(main,on); value = 1; }; \
        }; \
    }

#define EDEN_MODULE_BASE(name,fnc) \
    scope = 2; \
    scopeCurator = 0; \
    author = "Root, Azer0"; \
    displayName = name; \
    category = "RONIM"; \
    function = QFUNC(fnc); \
    functionPriority = 1; \
    isGlobal = 0; \
    isTriggerActivated = 0; \
    isDisposable = 0; \
    is3DEN = 0; \
    icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa"

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
            class Checkbox;
            class ModuleDescription;
        };
        class ModuleDescription;
    };

    class RONIM_Module_Settings: Module_F {
        EDEN_MODULE_BASE(ECSTRING(main,eden_settings),edenSettings);
        class Attributes: AttributesBase {
            #include "settingsAttributes.inc.hpp"
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = ECSTRING(main,eden_settings_desc);
        };
    };

    class RONIM_Module_Exempt: Module_F {
        EDEN_MODULE_BASE(ECSTRING(main,eden_exempt),edenExempt);
        class Attributes: AttributesBase {
            class RONIM_E_value: Checkbox {
                property = "RONIM_E_value";
                displayName = ECSTRING(main,eden_exempt_value);
                tooltip = ECSTRING(main,eden_exempt_value_desc);
                typeName = "BOOL";
                defaultValue = "true";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = ECSTRING(main,eden_exempt_desc);
            sync[] = {"AnyBrain"};
        };
    };
};
