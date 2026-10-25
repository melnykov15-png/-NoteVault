const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const files = [];
function walk(dir) { for (const entry of fs.readdirSync(dir, {withFileTypes:true})) { if (entry.name.startsWith('.') || ['Scripts','Docs','NoteVault.xcodeproj'].includes(entry.name)) continue; const p = path.join(dir,entry.name); if(entry.isDirectory()) walk(p); else if(entry.name.endsWith('.swift')) files.push(path.relative(root,p).replaceAll('\\','/')); } }
walk(root); files.sort();
let next=1; const id=()=> (next++).toString(16).toUpperCase().padStart(24,'0');
const project=id(), group=id(), products=id(), app=id(), tests=id(), appProduct=id(), testProduct=id(), appSources=id(), testSources=id(), appFrameworks=id(), testFrameworks=id(), appResources=id(), proxy=id(), dependency=id();
const objects=[]; const add=(i,v)=>objects.push(`${i} = { ${v} };`);
const refs=[]; const buildsApp=[], buildsTests=[];
for(const file of files) { const ref=id(),build=id(); refs.push(ref); add(ref,`isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "${file}"; sourceTree = SOURCE_ROOT;`); add(build,`isa = PBXBuildFile; fileRef = ${ref};`); (file.startsWith('Tests/')?buildsTests:buildsApp).push(build); }
add(appProduct,'isa = PBXFileReference; explicitFileType = wrapper.application; path = NoteVault.app; sourceTree = BUILT_PRODUCTS_DIR;');
add(testProduct,'isa = PBXFileReference; explicitFileType = wrapper.cfbundle; path = NoteVaultTests.xctest; sourceTree = BUILT_PRODUCTS_DIR;');
add(group,`isa = PBXGroup; children = (${refs.join(',')},${products}); sourceTree = "<group>";`);
add(products,`isa = PBXGroup; children = (${appProduct},${testProduct}); name = Products; sourceTree = "<group>";`);
for (const [i,type,builds] of [[appSources,'PBXSourcesBuildPhase',buildsApp],[testSources,'PBXSourcesBuildPhase',buildsTests],[appFrameworks,'PBXFrameworksBuildPhase',[]],[testFrameworks,'PBXFrameworksBuildPhase',[]],[appResources,'PBXResourcesBuildPhase',[]]]) add(i,`isa = ${type}; buildActionMask = 2147483647; files = (${builds.join(',')}); runOnlyForDeploymentPostprocessing = 0;`);
function configs(extra) { const debug=id(),release=id(),list=id(); for(const [i,name] of [[debug,'Debug'],[release,'Release']]) add(i,`isa = XCBuildConfiguration; name = ${name}; buildSettings = { ${extra} SWIFT_OPTIMIZATION_LEVEL = "${name==='Debug'?'-Onone':'-O'}"; ${name==='Debug'?'ENABLE_TESTABILITY = YES; DEBUG_INFORMATION_FORMAT = dwarf;':'DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";'} };`); add(list,`isa = XCConfigurationList; buildConfigurations = (${debug},${release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;`); return list; }
const projectConfigs = configs('SDKROOT = iphoneos; IPHONEOS_DEPLOYMENT_TARGET = 17.0; SWIFT_VERSION = 6.0; CLANG_ENABLE_MODULES = YES; SWIFT_STRICT_CONCURRENCY = complete;');
const common='GENERATE_INFOPLIST_FILE = YES; TARGETED_DEVICE_FAMILY = 1; CODE_SIGN_STYLE = Automatic; CURRENT_PROJECT_VERSION = 1; MARKETING_VERSION = 0.1.0; SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";';
const appConfigs=configs(`${common} PRODUCT_BUNDLE_IDENTIFIER = org.notevault.local; PRODUCT_NAME = "$(TARGET_NAME)"; INFOPLIST_KEY_CFBundleDisplayName = NoteVault; INFOPLIST_KEY_UILaunchScreen_Generation = YES; INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES; INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO; INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;`);
const testConfigs=configs(`${common} PRODUCT_BUNDLE_IDENTIFIER = org.notevault.local.tests; PRODUCT_NAME = "$(TARGET_NAME)"; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/NoteVault.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/NoteVault"; BUNDLE_LOADER = "$(TEST_HOST)";`);
add(proxy,`isa = PBXContainerItemProxy; containerPortal = ${project}; proxyType = 1; remoteGlobalIDString = ${app}; remoteInfo = NoteVault;`);
add(dependency,`isa = PBXTargetDependency; target = ${app}; targetProxy = ${proxy};`);
add(app,`isa = PBXNativeTarget; buildConfigurationList = ${appConfigs}; buildPhases = (${appSources},${appFrameworks},${appResources}); buildRules = (); dependencies = (); name = NoteVault; productName = NoteVault; productReference = ${appProduct}; productType = "com.apple.product-type.application";`);
add(tests,`isa = PBXNativeTarget; buildConfigurationList = ${testConfigs}; buildPhases = (${testSources},${testFrameworks}); buildRules = (); dependencies = (${dependency}); name = NoteVaultTests; productName = NoteVaultTests; productReference = ${testProduct}; productType = "com.apple.product-type.bundle.unit-test";`);
add(project,`isa = PBXProject; attributes = { LastUpgradeCheck = 1600; }; buildConfigurationList = ${projectConfigs}; compatibilityVersion = "Xcode 14.0"; developmentRegion = ru; knownRegions = (ru,en,Base); mainGroup = ${group}; productRefGroup = ${products}; projectDirPath = ""; projectRoot = ""; targets = (${app},${tests});`);
fs.writeFileSync(path.join(root,'NoteVault.xcodeproj/project.pbxproj'),`// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n${Object.entries(Object.groupBy(objects, line => line.match(/isa = (\w+)/)[1])).map(([type, lines]) => '/* Begin ' + type + ' section */\n' + lines.join('\n') + '\n/* End ' + type + ' section */').join('\n').replace(/(\b(?:children|files|buildConfigurations|buildPhases|dependencies|targets|knownRegions) = \()([^)]*)(\))/g, (_, a, b, c) => a + b + (b && !b.endsWith(',') ? ',' : '') + c)}\n}; rootObject = ${project}; }\n`);
const buildable=(target,name)=>`<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="${target}" BuildableName="${name}" BlueprintName="${name.split('.')[0]}" ReferencedContainer="container:NoteVault.xcodeproj"/>`;
fs.writeFileSync(path.join(root,'NoteVault.xcodeproj/xcshareddata/xcschemes/NoteVault.xcscheme'),`<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">${buildable(app,'NoteVault.app')}</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">${buildable(tests,'NoteVaultTests.xctest')}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">${buildable(app,'NoteVault.app')}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">${buildable(app,'NoteVault.app')}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>`);
console.log(`Generated project with ${files.length} Swift files and shared test scheme.`);


