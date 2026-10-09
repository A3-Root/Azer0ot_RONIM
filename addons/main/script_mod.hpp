#define MAINPREFIX z
#define PREFIX azeroot_ronim

#include "\z\azeroot_ronim\addons\main\script_version.hpp"

#define VERSION MAJOR.MINOR.PATCH.BUILD
#define VERSION_AR MAJOR,MINOR,PATCH,BUILD

// HEMTT check needs a quoted version
#define VERSION_CONFIG version = QUOTE(VERSION); versionStr = QUOTE(VERSION); versionAr[] = {VERSION_AR}

#define REQUIRED_VERSION 2.18
