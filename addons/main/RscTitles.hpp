// NVG overlay, drawn under the HUD. Draw order = control order: flash, tube mask, fillers, reticle.
// Every position is set per frame by fnc_maskUpdate.
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
            class Flash {
                idc = IDC_FLASH;
                type = 0;
                style = 0;
                x = "safeZoneXAbs";
                y = "safeZoneY";
                w = "safeZoneWAbs";
                h = "safeZoneH";
                text = "";
                font = "RobotoCondensed";
                sizeEx = 0.04;
                colorText[] = {0, 0, 0, 0};
                colorBackground[] = {0.88, 1, 0.88, 0};
            };
            class Mask: Flash {
                idc = IDC_MASK;
                style = 48;
                colorText[] = {1, 1, 1, 1};
                colorBackground[] = {0, 0, 0, 0};
            };
            class FillTop: Flash {
                idc = IDC_FILL_TOP;
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
            class Reticle: Mask {
                idc = IDC_RETICLE;
            };
        };
    };
};
