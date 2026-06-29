#!/usr/bin/env python3
"""Regenerate HerHealth.xcodeproj/project.pbxproj to include all Swift files.

CWD-agnostic: anchors to the script's own location to find the project root.
"""
import os
import hashlib

# Anchor to this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = SCRIPT_DIR  # Directory containing HerHealth.xcodeproj
SOURCE_DIR = os.path.join(PROJECT_ROOT, "HerHealth")
PBXPROJ_PATH = os.path.join(PROJECT_ROOT, "HerHealth.xcodeproj", "project.pbxproj")

PROJECT_NAME = "HerHealth"
BUNDLE_ID = "com.fionahu.HerHealth"
DEVELOPMENT_TEAM = ""
SWIFT_VERSION = "5.0"

# The inner source group (the "HerHealth" folder that actually contains source files).
# It is anchored to the project root, so we expose it as a single group with
# `path = HerHealth` and `sourceTree = "<group>"`.
INNER_GROUP_PATH = "HerHealth"


def uid(seed):
    return hashlib.md5(seed.encode("utf-8")).hexdigest()[:24].upper()


PROJECT_ID = uid("PROJECT_OBJECT")
NATIVE_TARGET = uid("NATIVE_TARGET")
PRODUCT_REF = uid("PRODUCT_REFERENCE")
PROJECT_GROUP = uid("MAIN_GROUP")
PRODUCTS_GROUP = uid("PRODUCTS_GROUP")
APPFRAMEWORKS_GROUP = uid("GROUP_APPFRAMEWORKS")
FRAMEWORKS_BUILD = uid("FRAMEWORKS_BUILD_PHASE")
SOURCES_BUILD = uid("SOURCES_BUILD_PHASE")
RESOURCES_BUILD = uid("RESOURCES_BUILD_PHASE")
MAIN_GROUP_HERHEALTH = uid("GROUP_HERHEALTH")
CONFIG_LIST = uid("CONFIG_LIST")
DEBUG_CONFIG = uid("DEBUG_CONFIG")
RELEASE_CONFIG = uid("RELEASE_CONFIG")
TARGET_CONFIG_LIST = uid("TARGET_CONFIG_LIST")
TARGET_DEBUG_CONFIG = uid("TARGET_DEBUG_CONFIG")
TARGET_RELEASE_CONFIG = uid("TARGET_RELEASE_CONFIG")

# Discover all Swift source files relative to SOURCE_DIR
swift_files = []
for root, dirs, files in os.walk(SOURCE_DIR):
    # Skip Preview Content / build artifacts
    if ".build" in root or "Preview Content" in root:
        continue
    for f in sorted(files):
        if f.endswith(".swift"):
            # Path relative to PROJECT_ROOT (so the inner group with path=HerHealth resolves)
            rel = os.path.relpath(os.path.join(root, f), PROJECT_ROOT)
            swift_files.append(rel)

# Map each swift file to a UUID
file_uids = {f: uid("FILE_" + f) for f in swift_files}
build_uids = {f: uid("BUILD_" + f) for f in swift_files}

# Build the group hierarchy anchored at the inner group (HerHealth/).
# We model paths relative to that anchor (i.e. strip the leading "HerHealth/" from rel paths).
group_uids = {}  # anchor-relative path -> uid
folder_uids = {}  # absolute (relative to PROJECT_ROOT) folder path -> uid


def ensure_group(anchor_path):
    """anchor_path is the path relative to the inner group (e.g. 'Stats' or 'Calm/Sub')."""
    if anchor_path in group_uids:
        return group_uids[anchor_path]
    group_uids[anchor_path] = uid("GROUP_DIR_" + anchor_path)
    if anchor_path:
        parent = os.path.dirname(anchor_path)
        ensure_group(parent)
    return group_uids[anchor_path]


for f in swift_files:
    # f is "HerHealth/Stats/StatsView.swift" — strip the "HerHealth/" prefix.
    assert f.startswith(INNER_GROUP_PATH + os.sep) or f == INNER_GROUP_PATH
    rel = f[len(INNER_GROUP_PATH) + 1:] if f != INNER_GROUP_PATH else ""
    dirpath = os.path.dirname(rel)
    if dirpath:
        ensure_group(dirpath)

# Children of each group (using anchor-relative keys)
group_children = {g: [] for g in group_uids.values()}

# Add file children
for f in swift_files:
    rel = f[len(INNER_GROUP_PATH) + 1:] if f != INNER_GROUP_PATH else ""
    parent_dir = os.path.dirname(rel)
    parent_uid = group_uids[parent_dir] if parent_dir else None
    if parent_uid is None:
        # File directly in the inner group (rare; we treat as child of MAIN_GROUP_HERHEALTH)
        continue
    group_children[parent_uid].append(("file", file_uids[f], os.path.basename(f)))

# Add sub-group children
for anchor_path, gid in group_uids.items():
    if not anchor_path:
        continue
    parent = os.path.dirname(anchor_path)
    parent_uid = group_uids[parent] if parent else None
    if parent_uid is None:
        # Anchor path is empty; these belong directly under MAIN_GROUP_HERHEALTH
        continue
    name = os.path.basename(anchor_path)
    group_children[parent_uid].append(("group", gid, name))

# Sort children: groups first, then files, alphabetically
for gid in group_children:
    group_children[gid].sort(key=lambda c: (0 if c[0] == "group" else 1, c[2]))


# Build pbxproj
out = []
out.append("// !$*UTF8*$!")
out.append("{")
out.append("\tarchiveVersion = 1;")
out.append("\tclasses = {")
out.append("\t};")
out.append("\tobjectVersion = 56;")
out.append("\tobjects = {")
out.append("")

# PBXBuildFile
out.append("/* Begin PBXBuildFile section */")
for f in swift_files:
    out.append(
        f"\t\t{build_uids[f]} /* {os.path.basename(f)} in Sources */ = "
        f"{{isa = PBXBuildFile; fileRef = {file_uids[f]} /* {os.path.basename(f)} */; }};"
    )
out.append("/* End PBXBuildFile section */")
out.append("")

# PBXFileReference (Swift files + product)
out.append("/* Begin PBXFileReference section */")
for f in swift_files:
    out.append(
        f"\t\t{file_uids[f]} /* {os.path.basename(f)} */ = "
        f'{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; '
        f'path = "{os.path.basename(f)}"; sourceTree = "<group>"; }};'
    )
out.append(
    f"\t\t{PRODUCT_REF} /* {PROJECT_NAME}.app */ = "
    f'{{isa = PBXFileReference; explicitFileType = wrapper.application; '
    f'includeInIndex = 0; path = "{PROJECT_NAME}.app"; sourceTree = BUILT_PRODUCTS_DIR; }};'
)
out.append("/* End PBXFileReference section */")
out.append("")

# PBXFrameworksBuildPhase
out.append("/* Begin PBXFrameworksBuildPhase section */")
out.append(f"\t\t{FRAMEWORKS_BUILD} /* Frameworks */ = {{")
out.append("\t\t\tisa = PBXFrameworksBuildPhase;")
out.append("\t\t\tbuildActionMask = 2147483647;")
out.append("\t\t\tfiles = (")
out.append("\t\t\t);")
out.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
out.append("\t\t};")
out.append("/* End PBXFrameworksBuildPhase section */")
out.append("")

# PBXGroup
out.append("/* Begin PBXGroup section */")
# Main group (root)
out.append(f"\t\t{PROJECT_GROUP} = {{")
out.append("\t\t\tisa = PBXGroup;")
out.append("\t\t\tchildren = (")
out.append(f"\t\t\t\t{MAIN_GROUP_HERHEALTH} /* {PROJECT_NAME} */,")
out.append(f"\t\t\t\t{APPFRAMEWORKS_GROUP} /* Frameworks */,")
out.append(f"\t\t\t\t{PRODUCTS_GROUP} /* Products */,")
out.append("\t\t\t);")
out.append('\t\t\tsourceTree = "<group>";')
out.append("\t\t};")

# Products group
out.append(f"\t\t{PRODUCTS_GROUP} /* Products */ = {{")
out.append("\t\t\tisa = PBXGroup;")
out.append("\t\t\tchildren = (")
out.append(f"\t\t\t\t{PRODUCT_REF} /* {PROJECT_NAME}.app */,")
out.append("\t\t\t);")
out.append("\t\t\tname = Products;")
out.append('\t\t\tsourceTree = "<group>";')
out.append("\t\t};")

# Frameworks group
out.append(f"\t\t{APPFRAMEWORKS_GROUP} /* Frameworks */ = {{")
out.append("\t\t\tisa = PBXGroup;")
out.append("\t\t\tchildren = (")
out.append("\t\t\t);")
out.append("\t\t\tname = Frameworks;")
out.append('\t\t\tsourceTree = "<group>";')
out.append("\t\t};")

# HerHealth group (the inner group, with path = HerHealth anchored to project root)
out.append(f"\t\t{MAIN_GROUP_HERHEALTH} /* {PROJECT_NAME} */ = {{")
out.append("\t\t\tisa = PBXGroup;")
out.append("\t\t\tchildren = (")

# Add direct subdirectories of the inner group (anchor_path without parent)
direct_subgroups = []
direct_files = []
for anchor_path, gid in group_uids.items():
    if not anchor_path:
        continue
    parent = os.path.dirname(anchor_path)
    if parent:
        continue
    direct_subgroups.append((gid, os.path.basename(anchor_path)))

for gid, name in sorted(direct_subgroups, key=lambda x: x[1]):
    out.append(f"\t\t\t\t{gid} /* {name} */,")

# Direct files (those with no subdirectory)
for f in swift_files:
    rel = f[len(INNER_GROUP_PATH) + 1:] if f != INNER_GROUP_PATH else ""
    if not rel or "/" not in rel:
        # File directly in the inner group (or the inner group itself)
        out.append(f"\t\t\t\t{file_uids[f]} /* {os.path.basename(f)} */,")

out.append("\t\t\t);")
out.append(f"\t\t\tpath = {INNER_GROUP_PATH};")
out.append('\t\t\tsourceTree = "<group>";')
out.append("\t\t};")

# Sub-groups (recursively)
def emit_subgroup(anchor_path, gid):
    name = os.path.basename(anchor_path)
    out.append(f"\t\t{gid} /* {name} */ = {{")
    out.append("\t\t\tisa = PBXGroup;")
    out.append("\t\t\tchildren = (")
    for kind, child_uid, child_name in group_children[gid]:
        out.append(f"\t\t\t\t{child_uid} /* {child_name} */,")
    out.append("\t\t\t);")
    out.append(f"\t\t\tpath = {name};")
    out.append('\t\t\tsourceTree = "<group>";')
    out.append("\t\t};")


# Emit in sorted order for determinism
for anchor_path in sorted(group_uids.keys()):
    if anchor_path:
        emit_subgroup(anchor_path, group_uids[anchor_path])

out.append("/* End PBXGroup section */")
out.append("")

# PBXNativeTarget
out.append("/* Begin PBXNativeTarget section */")
out.append(f"\t\t{NATIVE_TARGET} /* {PROJECT_NAME} */ = {{")
out.append("\t\t\tisa = PBXNativeTarget;")
out.append(
    f"\t\t\tbuildConfigurationList = {TARGET_CONFIG_LIST} /* "
    f'Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;'
)
out.append("\t\t\tbuildPhases = (")
out.append(f"\t\t\t\t{SOURCES_BUILD} /* Sources */,")
out.append(f"\t\t\t\t{FRAMEWORKS_BUILD} /* Frameworks */,")
out.append(f"\t\t\t\t{RESOURCES_BUILD} /* Resources */,")
out.append("\t\t\t);")
out.append("\t\t\tbuildRules = (")
out.append("\t\t\t);")
out.append("\t\t\tdependencies = (")
out.append("\t\t\t);")
out.append(f"\t\t\tname = {PROJECT_NAME};")
out.append(f"\t\t\tproductName = {PROJECT_NAME};")
out.append(f"\t\t\tproductReference = {PRODUCT_REF} /* {PROJECT_NAME}.app */;")
out.append('\t\t\tproductType = "com.apple.product-type.application";')
out.append("\t\t};")
out.append("/* End PBXNativeTarget section */")
out.append("")

# PBXProject
out.append("/* Begin PBXProject section */")
out.append(f"\t\t{PROJECT_ID} /* Project object */ = {{")
out.append("\t\t\tisa = PBXProject;")
out.append("\t\t\tattributes = {")
out.append("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
out.append("\t\t\t\tLastSwiftUpdateCheck = 1640;")
out.append("\t\t\t\tLastUpgradeCheck = 1640;")
out.append("\t\t\t\tTargetAttributes = {")
out.append(f"\t\t\t\t\t{NATIVE_TARGET} = {{")
out.append('\t\t\t\t\t\tCreatedOnToolsVersion = 16.4;')
out.append("\t\t\t\t\t};")
out.append("\t\t\t\t};")
out.append("\t\t\t};")
out.append(
    f"\t\t\tbuildConfigurationList = {CONFIG_LIST} /* "
    f'Build configuration list for PBXProject "{PROJECT_NAME}" */;'
)
out.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
out.append("\t\t\tdevelopmentRegion = en;")
out.append("\t\t\thasScannedForEncodings = 0;")
out.append("\t\t\tknownRegions = (")
out.append("\t\t\t\ten,")
out.append("\t\t\t\tBase,")
out.append("\t\t\t);")
out.append(f"\t\t\tmainGroup = {PROJECT_GROUP};")
out.append(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;")
out.append('\t\t\tprojectDirPath = "";')
out.append('\t\t\tprojectRoot = "";')
out.append("\t\t\ttargets = (")
out.append(f"\t\t\t\t{NATIVE_TARGET} /* {PROJECT_NAME} */,")
out.append("\t\t\t);")
out.append("\t\t};")
out.append("/* End PBXProject section */")
out.append("")

# PBXResourcesBuildPhase
out.append("/* Begin PBXResourcesBuildPhase section */")
out.append(f"\t\t{RESOURCES_BUILD} /* Resources */ = {{")
out.append("\t\t\tisa = PBXResourcesBuildPhase;")
out.append("\t\t\tbuildActionMask = 2147483647;")
out.append("\t\t\tfiles = (")
out.append("\t\t\t);")
out.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
out.append("\t\t};")
out.append("/* End PBXResourcesBuildPhase section */")
out.append("")

# PBXSourcesBuildPhase
out.append("/* Begin PBXSourcesBuildPhase section */")
out.append(f"\t\t{SOURCES_BUILD} /* Sources */ = {{")
out.append("\t\t\tisa = PBXSourcesBuildPhase;")
out.append("\t\t\tbuildActionMask = 2147483647;")
out.append("\t\t\tfiles = (")
for f in swift_files:
    out.append(f"\t\t\t\t{build_uids[f]} /* {os.path.basename(f)} in Sources */,")
out.append("\t\t\t);")
out.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
out.append("\t\t};")
out.append("/* End PBXSourcesBuildPhase section */")
out.append("")

# XCBuildConfiguration (project level)
out.append("/* Begin XCBuildConfiguration section */")


def project_config(name, uid_):
    out.append(f"\t\t{uid_} /* {name} */ = {{")
    out.append("\t\t\tisa = XCBuildConfiguration;")
    out.append("\t\t\tbuildSettings = {")
    out.append("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
    out.append("\t\t\t\tCLANG_ANALYZER_NONNULL = YES;")
    out.append("\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;")
    out.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
    out.append("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
    out.append("\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;")
    out.append("\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;")
    out.append("\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;")
    out.append("\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_COMMA = YES;")
    out.append("\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;")
    out.append("\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;")
    out.append("\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;")
    out.append("\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;")
    out.append("\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;")
    out.append("\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;")
    out.append("\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;")
    out.append("\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;")
    out.append("\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;")
    out.append("\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;")
    out.append("\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;")
    out.append("\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;")
    out.append("\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;")
    out.append("\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;")
    out.append("\t\t\t\tCOPY_PHASE_STRIP = NO;")
    if name == "Debug":
        out.append("\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;")
        out.append("\t\t\t\tENABLE_TESTABILITY = YES;")
        out.append("\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;")
        out.append("\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;")
        out.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)");')
        out.append("\t\t\t\tONLY_ACTIVE_ARCH = YES;")
        out.append("\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;")
        out.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
    else:
        out.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
        out.append("\t\t\t\tENABLE_NS_ASSERTIONS = NO;")
        out.append("\t\t\t\tGCC_NDEBUG = YES;")
        out.append("\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;")
    out.append("\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;")
    out.append("\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;")
    out.append("\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;")
    out.append("\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;")
    out.append("\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;")
    out.append("\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;")
    out.append("\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;")
    out.append("\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;")
    out.append("\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;")
    out.append("\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;")
    out.append("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
    out.append("\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;")
    out.append("\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;")
    out.append("\t\t\t\tMTL_FAST_MATH = YES;")
    out.append("\t\t\t\tSDKROOT = iphoneos;")
    out.append("\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;")
    out.append(f"\t\t\t\tSWIFT_VERSION = {SWIFT_VERSION};")
    out.append("\t\t\t};")
    out.append("\t\t\tname = " + name + ";")
    out.append("\t\t};")


project_config("Debug", DEBUG_CONFIG)
project_config("Release", RELEASE_CONFIG)


# Target level configurations
def target_config(name, uid_):
    out.append(f"\t\t{uid_} /* {name} */ = {{")
    out.append("\t\t\tisa = XCBuildConfiguration;")
    out.append("\t\t\tbuildSettings = {")
    out.append("\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;")
    out.append("\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;")
    out.append("\t\t\t\tCODE_SIGN_STYLE = Automatic;")
    out.append("\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
    out.append('\t\t\t\tDEVELOPMENT_ASSET_PATHS = "\\"HerHealth/Preview Content\\"";')
    out.append("\t\t\t\tENABLE_PREVIEWS = YES;")
    out.append("\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
    out.append("\t\t\t\tINFOPLIST_FILE = HerHealth/App/Info.plist;")
    out.append("\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;")
    out.append("\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;")
    out.append("\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;")
    out.append(
        "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "
        '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown '
        'UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";'
    )
    out.append(
        "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "
        '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown '
        'UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";'
    )
    out.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";')
    out.append("\t\t\t\tMARKETING_VERSION = 1.0;")
    out.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";')
    out.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    out.append("\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;")
    out.append(f"\t\t\t\tSWIFT_VERSION = {SWIFT_VERSION};")
    out.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    out.append("\t\t\t};")
    out.append("\t\t\tname = " + name + ";")
    out.append("\t\t};")


target_config("Debug", TARGET_DEBUG_CONFIG)
target_config("Release", TARGET_RELEASE_CONFIG)
out.append("/* End XCBuildConfiguration section */")
out.append("")

# XCConfigurationList
out.append("/* Begin XCConfigurationList section */")
out.append(
    f'\t\t{CONFIG_LIST} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{'
)
out.append("\t\t\tisa = XCConfigurationList;")
out.append("\t\t\tbuildConfigurations = (")
out.append(f"\t\t\t\t{DEBUG_CONFIG} /* Debug */,")
out.append(f"\t\t\t\t{RELEASE_CONFIG} /* Release */,")
out.append("\t\t\t);")
out.append("\t\t\tdefaultConfigurationIsVisible = 0;")
out.append("\t\t\tdefaultConfigurationName = Release;")
out.append("\t\t};")
out.append(
    f'\t\t{TARGET_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{'
)
out.append("\t\t\tisa = XCConfigurationList;")
out.append("\t\t\tbuildConfigurations = (")
out.append(f"\t\t\t\t{TARGET_DEBUG_CONFIG} /* Debug */,")
out.append(f"\t\t\t\t{TARGET_RELEASE_CONFIG} /* Release */,")
out.append("\t\t\t);")
out.append("\t\t\tdefaultConfigurationIsVisible = 0;")
out.append("\t\t\tdefaultConfigurationName = Release;")
out.append("\t\t};")
out.append("/* End XCConfigurationList section */")

out.append("\t};")
out.append(f"\trootObject = {PROJECT_ID} /* Project object */;")
out.append("}")

with open(PBXPROJ_PATH, "w") as f:
    f.write("\n".join(out))

print(f"Generated pbxproj with {len(swift_files)} Swift files at {PBXPROJ_PATH}")
for f in swift_files:
    print(f"  - {f}")
