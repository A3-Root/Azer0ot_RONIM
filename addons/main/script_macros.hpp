#include "\x\cba\addons\main\script_macros_common.hpp"

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

// Public API: functions\api\fnc_<name>.sqf -> azeroot_ronim_fnc_<name>
#define PREP_API(fncName) [QPATHTOF(functions\api\DOUBLES(fnc,fncName).sqf), QUOTE(TRIPLES(PREFIX,fnc,fncName))] call CBA_fnc_compileFunction
#define API(fncName) TRIPLES(PREFIX,fnc,fncName)
#define QAPI(fncName) QUOTE(API(fncName))

// All mod state lives under the main component namespace so every component shares it
#define MVAR(var) TRIPLES(PREFIX,main,var)
#define QMVAR(var) QUOTE(MVAR(var))
#define MFUNC(var) TRIPLES(PREFIX,main,DOUBLES(fnc,var))

// Live setting read: runtime override (Zeus/3DEN/API) wins over the CBA setting value
#define MSET(var) (missionNamespace getVariable [QUOTE(TRIPLES(PREFIX,main,DOUBLES(ov,var))), MVAR(var)])

// Texture paths
#define TEX(name) QPATHTOEF(main,data\name.paa)
#define TEX_ROOT "\z\azeroot_ronim\addons\main\data\"

// Mask display controls
#define IDC_FLASH 110
#define IDC_MASK 100
#define IDC_FILL_TOP 101
#define IDC_FILL_BOTTOM 102
#define IDC_FILL_LEFT 103
#define IDC_FILL_RIGHT 104
#define IDC_RETICLE 120
#define IDC_GROUP 200
#define IDC_PIP 201

// PiP render target, local to this client
#define PIP_TARGET "azeroot_ronim_nv"

#define TUBE_NONE 0
#define TUBE_MONO 1
#define TUBE_BINO 2
#define TUBE_QUAD 3
#define TUBE_NAMES ["none", "mono", "bino", "quad"]

#define RETICLE_STYLES ["dot", "cross", "chevron", "mildot"]

#define RONIM_DEBUG (MSET(debugLog))
#define RLOG(msg) if (RONIM_DEBUG) then { diag_log text format ["[RONIM] %1", msg] }
#define RLOG_1(msg,a1) if (RONIM_DEBUG) then { diag_log text format ["[RONIM] " + msg, a1] }
#define RLOG_2(msg,a1,a2) if (RONIM_DEBUG) then { diag_log text format ["[RONIM] " + msg, a1, a2] }
#define RLOG_3(msg,a1,a2,a3) if (RONIM_DEBUG) then { diag_log text format ["[RONIM] " + msg, a1, a2, a3] }
