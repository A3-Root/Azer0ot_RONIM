// Unit attribute: Attributes > RONIM > exempt. Only a true value is broadcast.
class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class RONIM_Attributes {
                displayName = ECSTRING(main,category);
                collapsed = 1;
                class Attributes {
                    class azeroot_ronim_exempt {
                        property = "azeroot_ronim_exempt";
                        displayName = ECSTRING(main,attr_exempt);
                        tooltip = ECSTRING(main,attr_exempt_desc);
                        control = "Checkbox";
                        typeName = "BOOL";
                        defaultValue = "false";
                        condition = "objectBrain";
                        expression = "if (_value && {isServer}) then { _this setVariable ['azeroot_ronim_main_exempt', true, true]; };";
                    };
                };
            };
        };
    };
};
