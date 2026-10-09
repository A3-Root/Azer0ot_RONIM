// NVG overlay. Draw order = control order: other-eye group, fillers, tube group, reticle.
// The tube group clips its children to the tube box: the PiP night vision picture (full screen
// size, shifted inside the group by sway), the tube flash and the mask texture on top.
// The other-eye group holds a PiP normal view for a monocular's naked eye (optional).
// Every position is set per frame by fnc_maskUpdate.
class RscText;
class RscPicture;
class RscControlsGroupNoScrollbars;

class RscTitles {
    class GVAR(display) {
        idd = -1;
        duration = 1e+011;
        fadeIn = 0;
        fadeOut = 0;
        movingEnable = 0;
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),_this select 0)]);
        onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(display),displayNull)]);

        class controls {
            class Eye: RscControlsGroupNoScrollbars {
                idc = IDC_EYE_GROUP;
                x = 0;
                y = 0;
                w = 0;
                h = 0;
                class controls {
                    class EyePip: RscPicture {
                        idc = IDC_EYE_PIP;
                        x = 0;
                        y = 0;
                        w = 0;
                        h = 0;
                        text = "";
                    };
                };
            };
            class FillTop: RscText {
                idc = IDC_FILL_TOP;
                x = 0;
                y = 0;
                w = 0;
                h = 0;
                text = "";
                colorBackground[] = {0, 0, 0, 1};
            };
            class FillBottom: FillTop {
                idc = IDC_FILL_BOTTOM;
            };
            class FillLeft: FillTop {
                idc = IDC_FILL_LEFT;
            };
            class FillRight: FillTop {
                idc = IDC_FILL_RIGHT;
            };
            class Tube: RscControlsGroupNoScrollbars {
                idc = IDC_GROUP;
                x = "safeZoneX";
                y = "safeZoneY";
                w = "safeZoneW";
                h = "safeZoneH";
                class controls {
                    class Pip: RscPicture {
                        idc = IDC_PIP;
                        x = 0;
                        y = 0;
                        w = 0;
                        h = 0;
                        text = "";
                    };
                    class Flash: RscText {
                        idc = IDC_FLASH;
                        x = 0;
                        y = 0;
                        w = 0;
                        h = 0;
                        text = "";
                        colorBackground[] = {0.88, 1, 0.88, 0};
                    };
                    class Mask: RscPicture {
                        idc = IDC_MASK;
                        x = 0;
                        y = 0;
                        w = 0;
                        h = 0;
                        text = "";
                    };
                };
            };
            class Reticle: RscPicture {
                idc = IDC_RETICLE;
                x = 0;
                y = 0;
                w = 0;
                h = 0;
                text = "";
            };
        };
    };
};
