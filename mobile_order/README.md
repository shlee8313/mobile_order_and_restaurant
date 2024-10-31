# mobile_order

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
mobile_order
├─ .gitignore
├─ .metadata
├─ .vscode
│  └─ settings.json
├─ analysis_options.yaml
├─ android
│  ├─ .gitignore
│  ├─ .gradle
│  │  ├─ 8.3
│  │  │  ├─ checksums
│  │  │  │  ├─ checksums.lock
│  │  │  │  ├─ md5-checksums.bin
│  │  │  │  └─ sha1-checksums.bin
│  │  │  ├─ dependencies-accessors
│  │  │  │  ├─ dependencies-accessors.lock
│  │  │  │  └─ gc.properties
│  │  │  ├─ executionHistory
│  │  │  │  ├─ executionHistory.bin
│  │  │  │  └─ executionHistory.lock
│  │  │  ├─ fileChanges
│  │  │  │  └─ last-build.bin
│  │  │  ├─ fileHashes
│  │  │  │  ├─ fileHashes.bin
│  │  │  │  ├─ fileHashes.lock
│  │  │  │  └─ resourceHashesCache.bin
│  │  │  ├─ gc.properties
│  │  │  └─ vcsMetadata
│  │  ├─ buildOutputCleanup
│  │  │  ├─ buildOutputCleanup.lock
│  │  │  ├─ cache.properties
│  │  │  └─ outputFiles.bin
│  │  ├─ file-system.probe
│  │  ├─ kotlin
│  │  │  ├─ errors
│  │  │  └─ sessions
│  │  └─ vcs-1
│  │     └─ gc.properties
│  ├─ app
│  │  ├─ build.gradle
│  │  ├─ google-services.json
│  │  └─ src
│  │     ├─ debug
│  │     │  └─ AndroidManifest.xml
│  │     ├─ main
│  │     │  ├─ AndroidManifest.xml
│  │     │  ├─ java
│  │     │  │  └─ io
│  │     │  │     └─ flutter
│  │     │  │        └─ plugins
│  │     │  │           └─ GeneratedPluginRegistrant.java
│  │     │  ├─ kotlin
│  │     │  │  └─ com
│  │     │  │     └─ example
│  │     │  │        └─ mobile_order
│  │     │  │           └─ MainActivity.kt
│  │     │  └─ res
│  │     │     ├─ drawable
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ drawable-v21
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ mipmap-hdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-mdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xxhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xxxhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ values
│  │     │     │  └─ styles.xml
│  │     │     └─ values-night
│  │     │        └─ styles.xml
│  │     └─ profile
│  │        └─ AndroidManifest.xml
│  ├─ build.gradle
│  ├─ gradle
│  │  └─ wrapper
│  │     ├─ gradle-wrapper.jar
│  │     └─ gradle-wrapper.properties
│  ├─ gradle.properties
│  ├─ gradlew
│  ├─ gradlew.bat
│  ├─ local.properties
│  └─ settings.gradle
├─ assets
│  └─ images
│     ├─ cart_icon.png
│     ├─ home_icon.png
│     ├─ profile_icon.png
│     ├─ restaurant_icon.png
│     └─ scan_icon.png
├─ firebase.json
├─ ios
│  ├─ .gitignore
│  ├─ Flutter
│  │  ├─ AppFrameworkInfo.plist
│  │  ├─ Debug.xcconfig
│  │  ├─ flutter_export_environment.sh
│  │  ├─ Generated.xcconfig
│  │  └─ Release.xcconfig
│  ├─ Runner
│  │  ├─ AppDelegate.swift
│  │  ├─ Assets.xcassets
│  │  │  ├─ AppIcon.appiconset
│  │  │  │  ├─ Contents.json
│  │  │  │  ├─ Icon-App-1024x1024@1x.png
│  │  │  │  ├─ Icon-App-20x20@1x.png
│  │  │  │  ├─ Icon-App-20x20@2x.png
│  │  │  │  ├─ Icon-App-20x20@3x.png
│  │  │  │  ├─ Icon-App-29x29@1x.png
│  │  │  │  ├─ Icon-App-29x29@2x.png
│  │  │  │  ├─ Icon-App-29x29@3x.png
│  │  │  │  ├─ Icon-App-40x40@1x.png
│  │  │  │  ├─ Icon-App-40x40@2x.png
│  │  │  │  ├─ Icon-App-40x40@3x.png
│  │  │  │  ├─ Icon-App-60x60@2x.png
│  │  │  │  ├─ Icon-App-60x60@3x.png
│  │  │  │  ├─ Icon-App-76x76@1x.png
│  │  │  │  ├─ Icon-App-76x76@2x.png
│  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│  │  │  └─ LaunchImage.imageset
│  │  │     ├─ Contents.json
│  │  │     ├─ LaunchImage.png
│  │  │     ├─ LaunchImage@2x.png
│  │  │     ├─ LaunchImage@3x.png
│  │  │     └─ README.md
│  │  ├─ Base.lproj
│  │  │  ├─ LaunchScreen.storyboard
│  │  │  └─ Main.storyboard
│  │  ├─ GeneratedPluginRegistrant.h
│  │  ├─ GeneratedPluginRegistrant.m
│  │  ├─ Info.plist
│  │  └─ Runner-Bridging-Header.h
│  ├─ Runner.xcodeproj
│  │  ├─ project.pbxproj
│  │  ├─ project.xcworkspace
│  │  │  ├─ contents.xcworkspacedata
│  │  │  └─ xcshareddata
│  │  │     ├─ IDEWorkspaceChecks.plist
│  │  │     └─ WorkspaceSettings.xcsettings
│  │  └─ xcshareddata
│  │     └─ xcschemes
│  │        └─ Runner.xcscheme
│  ├─ Runner.xcworkspace
│  │  ├─ contents.xcworkspacedata
│  │  └─ xcshareddata
│  │     ├─ IDEWorkspaceChecks.plist
│  │     └─ WorkspaceSettings.xcsettings
│  └─ RunnerTests
│     └─ RunnerTests.swift
├─ lib
│  ├─ core
│  │  ├─ config
│  │  │  └─ api_config.dart
│  │  ├─ theme
│  │  │  └─ app_theme.dart
│  │  └─ utils
│  │     └─ encryption_helper.dart
│  ├─ features
│  │  ├─ auth
│  │  │  ├─ controllers
│  │  │  │  └─ auth_controller.dart
│  │  │  └─ views
│  │  │     └─ login_page.dart
│  │  ├─ home
│  │  │  └─ views
│  │  │     └─ home_page.dart
│  │  ├─ order_list
│  │  │  └─ views
│  │  │     └─ order_list_page.dart
│  │  ├─ profile
│  │  │  └─ views
│  │  │     └─ profile_page.dart
│  │  ├─ qr_scanner
│  │  │  ├─ controllers
│  │  │  │  └─ qr_scanner_controller.dart
│  │  │  └─ views
│  │  │     └─ qr_scanner_page.dart
│  │  ├─ restaurants
│  │  │  ├─ controllers
│  │  │  │  └─ restaurants_list_controller.dart
│  │  │  └─ views
│  │  │     └─ restaurants_list_page.dart
│  │  └─ restaurant_menu
│  │     ├─ bindings
│  │     │  └─ restaurant_menu_binding.dart
│  │     ├─ controllers
│  │     │  └─ restaurant_menu_controller.dart
│  │     ├─ views
│  │     │  └─ restaurant_menu_page.dart
│  │     └─ widgets
│  │        ├─ cart_bottom_sheet.dart
│  │        └─ item_detail_bottom_sheet.dart
│  ├─ firebase_options.dart
│  ├─ main.dart
│  ├─ models
│  │  ├─ coupon.dart
│  │  ├─ menu.dart
│  │  ├─ order.dart
│  │  ├─ quick_orders.dart
│  │  ├─ restaurant.dart
│  │  ├─ review.dart
│  │  └─ user.dart
│  ├─ navigation
│  │  ├─ controllers
│  │  │  └─ navigation_controller.dart
│  │  └─ widgets
│  │     └─ bottom_navigation.dart
│  └─ services
│     ├─ auth_service.dart
│     └─ restaurant_service.dart
├─ linux
│  ├─ .gitignore
│  ├─ CMakeLists.txt
│  ├─ flutter
│  │  ├─ CMakeLists.txt
│  │  ├─ ephemeral
│  │  │  └─ .plugin_symlinks
│  │  │     ├─ flutter_secure_storage_linux
│  │  │     │  ├─ CHANGELOG.md
│  │  │     │  ├─ LICENSE
│  │  │     │  ├─ linux
│  │  │     │  │  ├─ CMakeLists.txt
│  │  │     │  │  ├─ flutter_secure_storage_linux_plugin.cc
│  │  │     │  │  └─ include
│  │  │     │  │     ├─ FHashTable.hpp
│  │  │     │  │     ├─ flutter_secure_storage_linux
│  │  │     │  │     │  └─ flutter_secure_storage_linux_plugin.h
│  │  │     │  │     ├─ json.hpp
│  │  │     │  │     └─ Secret.hpp
│  │  │     │  ├─ pubspec.yaml
│  │  │     │  └─ README.md
│  │  │     └─ path_provider_linux
│  │  │        ├─ AUTHORS
│  │  │        ├─ CHANGELOG.md
│  │  │        ├─ example
│  │  │        │  ├─ integration_test
│  │  │        │  │  └─ path_provider_test.dart
│  │  │        │  ├─ lib
│  │  │        │  │  └─ main.dart
│  │  │        │  ├─ linux
│  │  │        │  │  ├─ CMakeLists.txt
│  │  │        │  │  ├─ flutter
│  │  │        │  │  │  ├─ CMakeLists.txt
│  │  │        │  │  │  └─ generated_plugins.cmake
│  │  │        │  │  ├─ main.cc
│  │  │        │  │  ├─ my_application.cc
│  │  │        │  │  └─ my_application.h
│  │  │        │  ├─ pubspec.yaml
│  │  │        │  ├─ README.md
│  │  │        │  └─ test_driver
│  │  │        │     └─ integration_test.dart
│  │  │        ├─ lib
│  │  │        │  ├─ path_provider_linux.dart
│  │  │        │  └─ src
│  │  │        │     ├─ get_application_id.dart
│  │  │        │     ├─ get_application_id_real.dart
│  │  │        │     ├─ get_application_id_stub.dart
│  │  │        │     └─ path_provider_linux.dart
│  │  │        ├─ LICENSE
│  │  │        ├─ pubspec.yaml
│  │  │        ├─ README.md
│  │  │        └─ test
│  │  │           ├─ get_application_id_test.dart
│  │  │           └─ path_provider_linux_test.dart
│  │  ├─ generated_plugins.cmake
│  │  ├─ generated_plugin_registrant.cc
│  │  └─ generated_plugin_registrant.h
│  ├─ main.cc
│  ├─ my_application.cc
│  └─ my_application.h
├─ macos
│  ├─ .gitignore
│  ├─ Flutter
│  │  ├─ ephemeral
│  │  │  ├─ Flutter-Generated.xcconfig
│  │  │  └─ flutter_export_environment.sh
│  │  ├─ Flutter-Debug.xcconfig
│  │  ├─ Flutter-Release.xcconfig
│  │  └─ GeneratedPluginRegistrant.swift
│  ├─ Runner
│  │  ├─ AppDelegate.swift
│  │  ├─ Assets.xcassets
│  │  │  └─ AppIcon.appiconset
│  │  │     ├─ app_icon_1024.png
│  │  │     ├─ app_icon_128.png
│  │  │     ├─ app_icon_16.png
│  │  │     ├─ app_icon_256.png
│  │  │     ├─ app_icon_32.png
│  │  │     ├─ app_icon_512.png
│  │  │     ├─ app_icon_64.png
│  │  │     └─ Contents.json
│  │  ├─ Base.lproj
│  │  │  └─ MainMenu.xib
│  │  ├─ Configs
│  │  │  ├─ AppInfo.xcconfig
│  │  │  ├─ Debug.xcconfig
│  │  │  ├─ Release.xcconfig
│  │  │  └─ Warnings.xcconfig
│  │  ├─ DebugProfile.entitlements
│  │  ├─ Info.plist
│  │  ├─ MainFlutterWindow.swift
│  │  └─ Release.entitlements
│  ├─ Runner.xcodeproj
│  │  ├─ project.pbxproj
│  │  ├─ project.xcworkspace
│  │  │  └─ xcshareddata
│  │  │     └─ IDEWorkspaceChecks.plist
│  │  └─ xcshareddata
│  │     └─ xcschemes
│  │        └─ Runner.xcscheme
│  ├─ Runner.xcworkspace
│  │  ├─ contents.xcworkspacedata
│  │  └─ xcshareddata
│  │     └─ IDEWorkspaceChecks.plist
│  └─ RunnerTests
│     └─ RunnerTests.swift
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
├─ test
│  └─ widget_test.dart
├─ web
│  ├─ favicon.png
│  ├─ icons
│  │  ├─ Icon-192.png
│  │  ├─ Icon-512.png
│  │  ├─ Icon-maskable-192.png
│  │  └─ Icon-maskable-512.png
│  ├─ index.html
│  └─ manifest.json
└─ windows
   ├─ .gitignore
   ├─ CMakeLists.txt
   ├─ flutter
   │  ├─ CMakeLists.txt
   │  ├─ ephemeral
   │  │  ├─ .plugin_symlinks
   │  │  │  ├─ firebase_auth
   │  │  │  │  ├─ android
   │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  ├─ gradle
   │  │  │  │  │  │  └─ wrapper
   │  │  │  │  │  │     └─ gradle-wrapper.properties
   │  │  │  │  │  ├─ gradle.properties
   │  │  │  │  │  ├─ settings.gradle
   │  │  │  │  │  ├─ src
   │  │  │  │  │  │  └─ main
   │  │  │  │  │  │     ├─ AndroidManifest.xml
   │  │  │  │  │  │     └─ java
   │  │  │  │  │  │        └─ io
   │  │  │  │  │  │           └─ flutter
   │  │  │  │  │  │              └─ plugins
   │  │  │  │  │  │                 └─ firebase
   │  │  │  │  │  │                    └─ auth
   │  │  │  │  │  │                       ├─ AuthStateChannelStreamHandler.java
   │  │  │  │  │  │                       ├─ Constants.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseAuthPlugin.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseAuthPluginException.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseAuthRegistrar.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseAuthUser.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseMultiFactor.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseTotpSecret.java
   │  │  │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth.java
   │  │  │  │  │  │                       ├─ IdTokenChannelStreamHandler.java
   │  │  │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler.java
   │  │  │  │  │  │                       └─ PigeonParser.java
   │  │  │  │  │  └─ user-agent.gradle
   │  │  │  │  ├─ CHANGELOG.md
   │  │  │  │  ├─ example
   │  │  │  │  │  ├─ analysis_options.yaml
   │  │  │  │  │  ├─ android
   │  │  │  │  │  │  ├─ app
   │  │  │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  │  │  ├─ google-services.json
   │  │  │  │  │  │  │  └─ src
   │  │  │  │  │  │  │     ├─ debug
   │  │  │  │  │  │  │     │  └─ AndroidManifest.xml
   │  │  │  │  │  │  │     ├─ main
   │  │  │  │  │  │  │     │  ├─ AndroidManifest.xml
   │  │  │  │  │  │  │     │  ├─ java
   │  │  │  │  │  │  │     │  │  └─ io
   │  │  │  │  │  │  │     │  │     └─ flutter
   │  │  │  │  │  │  │     │  │        └─ plugins
   │  │  │  │  │  │  │     │  ├─ kotlin
   │  │  │  │  │  │  │     │  │  └─ io
   │  │  │  │  │  │  │     │  │     └─ flutter
   │  │  │  │  │  │  │     │  │        └─ plugins
   │  │  │  │  │  │  │     │  │           └─ firebase
   │  │  │  │  │  │  │     │  │              └─ auth
   │  │  │  │  │  │  │     │  │                 └─ example
   │  │  │  │  │  │  │     │  │                    └─ MainActivity.kt
   │  │  │  │  │  │  │     │  └─ res
   │  │  │  │  │  │  │     │     ├─ drawable
   │  │  │  │  │  │  │     │     │  └─ launch_background.xml
   │  │  │  │  │  │  │     │     ├─ drawable-v21
   │  │  │  │  │  │  │     │     │  └─ launch_background.xml
   │  │  │  │  │  │  │     │     ├─ mipmap-hdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-mdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xxhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xxxhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ values
   │  │  │  │  │  │  │     │     │  └─ styles.xml
   │  │  │  │  │  │  │     │     └─ values-night
   │  │  │  │  │  │  │     │        └─ styles.xml
   │  │  │  │  │  │  │     └─ profile
   │  │  │  │  │  │  │        └─ AndroidManifest.xml
   │  │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  │  ├─ gradle
   │  │  │  │  │  │  │  └─ wrapper
   │  │  │  │  │  │  │     └─ gradle-wrapper.properties
   │  │  │  │  │  │  ├─ gradle.properties
   │  │  │  │  │  │  └─ settings.gradle
   │  │  │  │  │  ├─ ios
   │  │  │  │  │  │  ├─ firebase_app_id_file.json
   │  │  │  │  │  │  ├─ Flutter
   │  │  │  │  │  │  │  ├─ AppFrameworkInfo.plist
   │  │  │  │  │  │  │  ├─ Debug.xcconfig
   │  │  │  │  │  │  │  └─ Release.xcconfig
   │  │  │  │  │  │  ├─ Podfile
   │  │  │  │  │  │  ├─ Runner
   │  │  │  │  │  │  │  ├─ AppDelegate.h
   │  │  │  │  │  │  │  ├─ AppDelegate.m
   │  │  │  │  │  │  │  ├─ AppDelegate.swift
   │  │  │  │  │  │  │  ├─ Assets.xcassets
   │  │  │  │  │  │  │  │  ├─ AppIcon.appiconset
   │  │  │  │  │  │  │  │  │  ├─ Contents.json
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │  │  │  │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │  │  │  │  │  │  │  │  └─ LaunchImage.imageset
   │  │  │  │  │  │  │  │     ├─ Contents.json
   │  │  │  │  │  │  │  │     ├─ LaunchImage.png
   │  │  │  │  │  │  │  │     ├─ LaunchImage@2x.png
   │  │  │  │  │  │  │  │     ├─ LaunchImage@3x.png
   │  │  │  │  │  │  │  │     └─ README.md
   │  │  │  │  │  │  │  ├─ Base.lproj
   │  │  │  │  │  │  │  │  ├─ LaunchScreen.storyboard
   │  │  │  │  │  │  │  │  └─ Main.storyboard
   │  │  │  │  │  │  │  ├─ GoogleService-Info.plist
   │  │  │  │  │  │  │  ├─ Info.plist
   │  │  │  │  │  │  │  ├─ main.m
   │  │  │  │  │  │  │  ├─ Runner-Bridging-Header.h
   │  │  │  │  │  │  │  └─ Runner.entitlements
   │  │  │  │  │  │  ├─ Runner.xcodeproj
   │  │  │  │  │  │  │  ├─ project.pbxproj
   │  │  │  │  │  │  │  ├─ project.xcworkspace
   │  │  │  │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │  │  │     ├─ swiftpm
   │  │  │  │  │  │  │  │     │  └─ configuration
   │  │  │  │  │  │  │  │     └─ WorkspaceSettings.xcsettings
   │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │     └─ xcschemes
   │  │  │  │  │  │  │        └─ Runner.xcscheme
   │  │  │  │  │  │  └─ Runner.xcworkspace
   │  │  │  │  │  │     ├─ contents.xcworkspacedata
   │  │  │  │  │  │     └─ xcshareddata
   │  │  │  │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │        ├─ swiftpm
   │  │  │  │  │  │        │  └─ configuration
   │  │  │  │  │  │        └─ WorkspaceSettings.xcsettings
   │  │  │  │  │  ├─ lib
   │  │  │  │  │  │  ├─ auth.dart
   │  │  │  │  │  │  ├─ firebase_options.dart
   │  │  │  │  │  │  ├─ main.dart
   │  │  │  │  │  │  └─ profile.dart
   │  │  │  │  │  ├─ macos
   │  │  │  │  │  │  ├─ firebase_app_id_file.json
   │  │  │  │  │  │  ├─ Flutter
   │  │  │  │  │  │  │  ├─ Flutter-Debug.xcconfig
   │  │  │  │  │  │  │  └─ Flutter-Release.xcconfig
   │  │  │  │  │  │  ├─ Podfile
   │  │  │  │  │  │  ├─ Runner
   │  │  │  │  │  │  │  ├─ AppDelegate.swift
   │  │  │  │  │  │  │  ├─ Assets.xcassets
   │  │  │  │  │  │  │  │  └─ AppIcon.appiconset
   │  │  │  │  │  │  │  │     ├─ app_icon_1024.png
   │  │  │  │  │  │  │  │     ├─ app_icon_128.png
   │  │  │  │  │  │  │  │     ├─ app_icon_16.png
   │  │  │  │  │  │  │  │     ├─ app_icon_256.png
   │  │  │  │  │  │  │  │     ├─ app_icon_32.png
   │  │  │  │  │  │  │  │     ├─ app_icon_512.png
   │  │  │  │  │  │  │  │     ├─ app_icon_64.png
   │  │  │  │  │  │  │  │     └─ Contents.json
   │  │  │  │  │  │  │  ├─ Base.lproj
   │  │  │  │  │  │  │  │  └─ MainMenu.xib
   │  │  │  │  │  │  │  ├─ Configs
   │  │  │  │  │  │  │  │  ├─ AppInfo.xcconfig
   │  │  │  │  │  │  │  │  ├─ Debug.xcconfig
   │  │  │  │  │  │  │  │  ├─ Release.xcconfig
   │  │  │  │  │  │  │  │  └─ Warnings.xcconfig
   │  │  │  │  │  │  │  ├─ DebugProfile.entitlements
   │  │  │  │  │  │  │  ├─ GoogleService-Info.plist
   │  │  │  │  │  │  │  ├─ Info.plist
   │  │  │  │  │  │  │  ├─ MainFlutterWindow.swift
   │  │  │  │  │  │  │  └─ Release.entitlements
   │  │  │  │  │  │  ├─ Runner.xcodeproj
   │  │  │  │  │  │  │  ├─ project.pbxproj
   │  │  │  │  │  │  │  ├─ project.xcworkspace
   │  │  │  │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │  │     └─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │     └─ xcschemes
   │  │  │  │  │  │  │        └─ Runner.xcscheme
   │  │  │  │  │  │  └─ Runner.xcworkspace
   │  │  │  │  │  │     ├─ contents.xcworkspacedata
   │  │  │  │  │  │     └─ xcshareddata
   │  │  │  │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │        └─ WorkspaceSettings.xcsettings
   │  │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  │  ├─ README.md
   │  │  │  │  │  ├─ web
   │  │  │  │  │  │  ├─ favicon.png
   │  │  │  │  │  │  ├─ icons
   │  │  │  │  │  │  │  ├─ Icon-192.png
   │  │  │  │  │  │  │  ├─ Icon-512.png
   │  │  │  │  │  │  │  ├─ Icon-maskable-192.png
   │  │  │  │  │  │  │  └─ Icon-maskable-512.png
   │  │  │  │  │  │  ├─ index.html
   │  │  │  │  │  │  └─ manifest.json
   │  │  │  │  │  └─ windows
   │  │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │  │     ├─ flutter
   │  │  │  │  │     │  └─ CMakeLists.txt
   │  │  │  │  │     └─ runner
   │  │  │  │  │        ├─ CMakeLists.txt
   │  │  │  │  │        ├─ flutter_window.cpp
   │  │  │  │  │        ├─ flutter_window.h
   │  │  │  │  │        ├─ main.cpp
   │  │  │  │  │        ├─ resource.h
   │  │  │  │  │        ├─ resources
   │  │  │  │  │        │  └─ app_icon.ico
   │  │  │  │  │        ├─ runner.exe.manifest
   │  │  │  │  │        ├─ Runner.rc
   │  │  │  │  │        ├─ utils.cpp
   │  │  │  │  │        ├─ utils.h
   │  │  │  │  │        ├─ win32_window.cpp
   │  │  │  │  │        └─ win32_window.h
   │  │  │  │  ├─ ios
   │  │  │  │  │  ├─ Assets
   │  │  │  │  │  ├─ Classes
   │  │  │  │  │  │  ├─ firebase_auth_messages.g.m
   │  │  │  │  │  │  ├─ FLTAuthStateChannelStreamHandler.m
   │  │  │  │  │  │  ├─ FLTFirebaseAuthPlugin.m
   │  │  │  │  │  │  ├─ FLTIdTokenChannelStreamHandler.m
   │  │  │  │  │  │  ├─ FLTPhoneNumberVerificationStreamHandler.m
   │  │  │  │  │  │  ├─ PigeonParser.m
   │  │  │  │  │  │  ├─ Private
   │  │  │  │  │  │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │  │  │  │  │  │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │  │  │  │  │  │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │  │  │  │  │  │  │  └─ PigeonParser.h
   │  │  │  │  │  │  └─ Public
   │  │  │  │  │  │     ├─ CustomPigeonHeader.h
   │  │  │  │  │  │     ├─ firebase_auth_messages.g.h
   │  │  │  │  │  │     └─ FLTFirebaseAuthPlugin.h
   │  │  │  │  │  └─ firebase_auth.podspec
   │  │  │  │  ├─ lib
   │  │  │  │  │  ├─ firebase_auth.dart
   │  │  │  │  │  └─ src
   │  │  │  │  │     ├─ confirmation_result.dart
   │  │  │  │  │     ├─ firebase_auth.dart
   │  │  │  │  │     ├─ multi_factor.dart
   │  │  │  │  │     ├─ recaptcha_verifier.dart
   │  │  │  │  │     ├─ user.dart
   │  │  │  │  │     └─ user_credential.dart
   │  │  │  │  ├─ LICENSE
   │  │  │  │  ├─ macos
   │  │  │  │  │  ├─ Assets
   │  │  │  │  │  ├─ Classes
   │  │  │  │  │  │  ├─ firebase_auth_messages.g.m
   │  │  │  │  │  │  ├─ FLTAuthStateChannelStreamHandler.m
   │  │  │  │  │  │  ├─ FLTFirebaseAuthPlugin.m
   │  │  │  │  │  │  ├─ FLTIdTokenChannelStreamHandler.m
   │  │  │  │  │  │  ├─ FLTPhoneNumberVerificationStreamHandler.m
   │  │  │  │  │  │  ├─ PigeonParser.m
   │  │  │  │  │  │  ├─ Private
   │  │  │  │  │  │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │  │  │  │  │  │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │  │  │  │  │  │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │  │  │  │  │  │  │  └─ PigeonParser.h
   │  │  │  │  │  │  └─ Public
   │  │  │  │  │  │     ├─ CustomPigeonHeader.h
   │  │  │  │  │  │     ├─ firebase_auth_messages.g.h
   │  │  │  │  │  │     └─ FLTFirebaseAuthPlugin.h
   │  │  │  │  │  └─ firebase_auth.podspec
   │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  ├─ README.md
   │  │  │  │  ├─ test
   │  │  │  │  │  ├─ firebase_auth_test.dart
   │  │  │  │  │  ├─ mock.dart
   │  │  │  │  │  └─ user_test.dart
   │  │  │  │  └─ windows
   │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │     ├─ firebase_auth_plugin.cpp
   │  │  │  │     ├─ firebase_auth_plugin.h
   │  │  │  │     ├─ firebase_auth_plugin_c_api.cpp
   │  │  │  │     ├─ include
   │  │  │  │     │  └─ firebase_auth
   │  │  │  │     │     └─ firebase_auth_plugin_c_api.h
   │  │  │  │     ├─ messages.g.cpp
   │  │  │  │     ├─ messages.g.h
   │  │  │  │     ├─ plugin_version.h.in
   │  │  │  │     └─ test
   │  │  │  │        └─ firebase_auth_plugin_test.cpp
   │  │  │  ├─ firebase_core
   │  │  │  │  ├─ android
   │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  ├─ gradle
   │  │  │  │  │  │  └─ wrapper
   │  │  │  │  │  │     └─ gradle-wrapper.properties
   │  │  │  │  │  ├─ gradle.properties
   │  │  │  │  │  ├─ settings.gradle
   │  │  │  │  │  ├─ src
   │  │  │  │  │  │  └─ main
   │  │  │  │  │  │     ├─ AndroidManifest.xml
   │  │  │  │  │  │     └─ java
   │  │  │  │  │  │        └─ io
   │  │  │  │  │  │           └─ flutter
   │  │  │  │  │  │              └─ plugins
   │  │  │  │  │  │                 └─ firebase
   │  │  │  │  │  │                    └─ core
   │  │  │  │  │  │                       ├─ FlutterFirebaseCorePlugin.java
   │  │  │  │  │  │                       ├─ FlutterFirebaseCoreRegistrar.java
   │  │  │  │  │  │                       ├─ FlutterFirebasePlugin.java
   │  │  │  │  │  │                       ├─ FlutterFirebasePluginRegistry.java
   │  │  │  │  │  │                       └─ GeneratedAndroidFirebaseCore.java
   │  │  │  │  │  └─ user-agent.gradle
   │  │  │  │  ├─ CHANGELOG.md
   │  │  │  │  ├─ example
   │  │  │  │  │  ├─ analysis_options.yaml
   │  │  │  │  │  ├─ android
   │  │  │  │  │  │  ├─ app
   │  │  │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  │  │  ├─ google-services.json
   │  │  │  │  │  │  │  └─ src
   │  │  │  │  │  │  │     ├─ debug
   │  │  │  │  │  │  │     │  └─ AndroidManifest.xml
   │  │  │  │  │  │  │     ├─ main
   │  │  │  │  │  │  │     │  ├─ AndroidManifest.xml
   │  │  │  │  │  │  │     │  ├─ java
   │  │  │  │  │  │  │     │  │  └─ io
   │  │  │  │  │  │  │     │  │     └─ flutter
   │  │  │  │  │  │  │     │  │        └─ plugins
   │  │  │  │  │  │  │     │  ├─ kotlin
   │  │  │  │  │  │  │     │  │  └─ io
   │  │  │  │  │  │  │     │  │     └─ flutter
   │  │  │  │  │  │  │     │  │        └─ plugins
   │  │  │  │  │  │  │     │  │           └─ firebasecoreexample
   │  │  │  │  │  │  │     │  │              └─ MainActivity.kt
   │  │  │  │  │  │  │     │  └─ res
   │  │  │  │  │  │  │     │     ├─ drawable
   │  │  │  │  │  │  │     │     │  └─ launch_background.xml
   │  │  │  │  │  │  │     │     ├─ drawable-v21
   │  │  │  │  │  │  │     │     │  └─ launch_background.xml
   │  │  │  │  │  │  │     │     ├─ mipmap-hdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-mdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xxhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ mipmap-xxxhdpi
   │  │  │  │  │  │  │     │     │  └─ ic_launcher.png
   │  │  │  │  │  │  │     │     ├─ values
   │  │  │  │  │  │  │     │     │  └─ styles.xml
   │  │  │  │  │  │  │     │     └─ values-night
   │  │  │  │  │  │  │     │        └─ styles.xml
   │  │  │  │  │  │  │     └─ profile
   │  │  │  │  │  │  │        └─ AndroidManifest.xml
   │  │  │  │  │  │  ├─ build.gradle
   │  │  │  │  │  │  ├─ gradle
   │  │  │  │  │  │  │  └─ wrapper
   │  │  │  │  │  │  │     └─ gradle-wrapper.properties
   │  │  │  │  │  │  ├─ gradle.properties
   │  │  │  │  │  │  └─ settings.gradle
   │  │  │  │  │  ├─ ios
   │  │  │  │  │  │  ├─ Flutter
   │  │  │  │  │  │  │  ├─ AppFrameworkInfo.plist
   │  │  │  │  │  │  │  ├─ Debug.xcconfig
   │  │  │  │  │  │  │  └─ Release.xcconfig
   │  │  │  │  │  │  ├─ Podfile
   │  │  │  │  │  │  ├─ Runner
   │  │  │  │  │  │  │  ├─ AppDelegate.h
   │  │  │  │  │  │  │  ├─ AppDelegate.m
   │  │  │  │  │  │  │  ├─ Assets.xcassets
   │  │  │  │  │  │  │  │  ├─ AppIcon.appiconset
   │  │  │  │  │  │  │  │  │  ├─ Contents.json
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │  │  │  │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │  │  │  │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │  │  │  │  │  │  │  │  └─ LaunchImage.imageset
   │  │  │  │  │  │  │  │     ├─ Contents.json
   │  │  │  │  │  │  │  │     ├─ LaunchImage.png
   │  │  │  │  │  │  │  │     ├─ LaunchImage@2x.png
   │  │  │  │  │  │  │  │     ├─ LaunchImage@3x.png
   │  │  │  │  │  │  │  │     └─ README.md
   │  │  │  │  │  │  │  ├─ Base.lproj
   │  │  │  │  │  │  │  │  ├─ LaunchScreen.storyboard
   │  │  │  │  │  │  │  │  └─ Main.storyboard
   │  │  │  │  │  │  │  ├─ Info.plist
   │  │  │  │  │  │  │  └─ main.m
   │  │  │  │  │  │  ├─ Runner.xcodeproj
   │  │  │  │  │  │  │  ├─ project.pbxproj
   │  │  │  │  │  │  │  ├─ project.xcworkspace
   │  │  │  │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │  │  │     └─ swiftpm
   │  │  │  │  │  │  │  │        └─ configuration
   │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │     └─ xcschemes
   │  │  │  │  │  │  │        └─ Runner.xcscheme
   │  │  │  │  │  │  └─ Runner.xcworkspace
   │  │  │  │  │  │     ├─ contents.xcworkspacedata
   │  │  │  │  │  │     └─ xcshareddata
   │  │  │  │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │        └─ swiftpm
   │  │  │  │  │  │           └─ configuration
   │  │  │  │  │  ├─ lib
   │  │  │  │  │  │  ├─ firebase_options.dart
   │  │  │  │  │  │  └─ main.dart
   │  │  │  │  │  ├─ macos
   │  │  │  │  │  │  ├─ Flutter
   │  │  │  │  │  │  │  ├─ Flutter-Debug.xcconfig
   │  │  │  │  │  │  │  └─ Flutter-Release.xcconfig
   │  │  │  │  │  │  ├─ Podfile
   │  │  │  │  │  │  ├─ Runner
   │  │  │  │  │  │  │  ├─ AppDelegate.swift
   │  │  │  │  │  │  │  ├─ Assets.xcassets
   │  │  │  │  │  │  │  │  └─ AppIcon.appiconset
   │  │  │  │  │  │  │  │     ├─ app_icon_1024.png
   │  │  │  │  │  │  │  │     ├─ app_icon_128.png
   │  │  │  │  │  │  │  │     ├─ app_icon_16.png
   │  │  │  │  │  │  │  │     ├─ app_icon_256.png
   │  │  │  │  │  │  │  │     ├─ app_icon_32.png
   │  │  │  │  │  │  │  │     ├─ app_icon_512.png
   │  │  │  │  │  │  │  │     ├─ app_icon_64.png
   │  │  │  │  │  │  │  │     └─ Contents.json
   │  │  │  │  │  │  │  ├─ Base.lproj
   │  │  │  │  │  │  │  │  └─ MainMenu.xib
   │  │  │  │  │  │  │  ├─ Configs
   │  │  │  │  │  │  │  │  ├─ AppInfo.xcconfig
   │  │  │  │  │  │  │  │  ├─ Debug.xcconfig
   │  │  │  │  │  │  │  │  ├─ Release.xcconfig
   │  │  │  │  │  │  │  │  └─ Warnings.xcconfig
   │  │  │  │  │  │  │  ├─ DebugProfile.entitlements
   │  │  │  │  │  │  │  ├─ Info.plist
   │  │  │  │  │  │  │  ├─ MainFlutterWindow.swift
   │  │  │  │  │  │  │  └─ Release.entitlements
   │  │  │  │  │  │  ├─ Runner.xcodeproj
   │  │  │  │  │  │  │  ├─ project.pbxproj
   │  │  │  │  │  │  │  ├─ project.xcworkspace
   │  │  │  │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │  │     └─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │  │  └─ xcshareddata
   │  │  │  │  │  │  │     └─ xcschemes
   │  │  │  │  │  │  │        └─ Runner.xcscheme
   │  │  │  │  │  │  └─ Runner.xcworkspace
   │  │  │  │  │  │     ├─ contents.xcworkspacedata
   │  │  │  │  │  │     └─ xcshareddata
   │  │  │  │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │  │  │  │  │        └─ WorkspaceSettings.xcsettings
   │  │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  │  ├─ README.md
   │  │  │  │  │  ├─ web
   │  │  │  │  │  │  ├─ favicon.png
   │  │  │  │  │  │  ├─ icons
   │  │  │  │  │  │  │  ├─ Icon-192.png
   │  │  │  │  │  │  │  ├─ Icon-512.png
   │  │  │  │  │  │  │  ├─ Icon-maskable-192.png
   │  │  │  │  │  │  │  └─ Icon-maskable-512.png
   │  │  │  │  │  │  ├─ index.html
   │  │  │  │  │  │  └─ manifest.json
   │  │  │  │  │  └─ windows
   │  │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │  │     ├─ flutter
   │  │  │  │  │     │  └─ CMakeLists.txt
   │  │  │  │  │     └─ runner
   │  │  │  │  │        ├─ CMakeLists.txt
   │  │  │  │  │        ├─ flutter_window.cpp
   │  │  │  │  │        ├─ flutter_window.h
   │  │  │  │  │        ├─ main.cpp
   │  │  │  │  │        ├─ resource.h
   │  │  │  │  │        ├─ resources
   │  │  │  │  │        │  └─ app_icon.ico
   │  │  │  │  │        ├─ runner.exe.manifest
   │  │  │  │  │        ├─ Runner.rc
   │  │  │  │  │        ├─ utils.cpp
   │  │  │  │  │        ├─ utils.h
   │  │  │  │  │        ├─ win32_window.cpp
   │  │  │  │  │        └─ win32_window.h
   │  │  │  │  ├─ ios
   │  │  │  │  │  ├─ firebase_core
   │  │  │  │  │  │  ├─ Package.swift
   │  │  │  │  │  │  └─ Sources
   │  │  │  │  │  │     └─ firebase_core
   │  │  │  │  │  │        ├─ FLTFirebaseCorePlugin.m
   │  │  │  │  │  │        ├─ FLTFirebasePlugin.m
   │  │  │  │  │  │        ├─ FLTFirebasePluginRegistry.m
   │  │  │  │  │  │        ├─ include
   │  │  │  │  │  │        │  └─ firebase_core
   │  │  │  │  │  │        │     ├─ FLTFirebaseCorePlugin.h
   │  │  │  │  │  │        │     ├─ FLTFirebasePlugin.h
   │  │  │  │  │  │        │     ├─ FLTFirebasePluginRegistry.h
   │  │  │  │  │  │        │     └─ messages.g.h
   │  │  │  │  │  │        ├─ messages.g.m
   │  │  │  │  │  │        └─ Resources
   │  │  │  │  │  ├─ firebase_core.podspec
   │  │  │  │  │  └─ firebase_sdk_version.rb
   │  │  │  │  ├─ lib
   │  │  │  │  │  ├─ firebase_core.dart
   │  │  │  │  │  └─ src
   │  │  │  │  │     ├─ firebase.dart
   │  │  │  │  │     ├─ firebase_app.dart
   │  │  │  │  │     └─ port_mapping.dart
   │  │  │  │  ├─ LICENSE
   │  │  │  │  ├─ macos
   │  │  │  │  │  ├─ firebase_core
   │  │  │  │  │  │  ├─ Package.swift
   │  │  │  │  │  │  └─ Sources
   │  │  │  │  │  │     └─ firebase_core
   │  │  │  │  │  │        ├─ FLTFirebaseCorePlugin.m
   │  │  │  │  │  │        ├─ FLTFirebasePlugin.m
   │  │  │  │  │  │        ├─ FLTFirebasePluginRegistry.m
   │  │  │  │  │  │        ├─ include
   │  │  │  │  │  │        │  └─ firebase_core
   │  │  │  │  │  │        │     ├─ FLTFirebaseCorePlugin.h
   │  │  │  │  │  │        │     ├─ FLTFirebasePlugin.h
   │  │  │  │  │  │        │     ├─ FLTFirebasePluginRegistry.h
   │  │  │  │  │  │        │     └─ messages.g.h
   │  │  │  │  │  │        ├─ messages.g.m
   │  │  │  │  │  │        └─ Resources
   │  │  │  │  │  └─ firebase_core.podspec
   │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  ├─ README.md
   │  │  │  │  ├─ test
   │  │  │  │  │  └─ firebase_core_test.dart
   │  │  │  │  └─ windows
   │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │     ├─ firebase_core_plugin.cpp
   │  │  │  │     ├─ firebase_core_plugin.h
   │  │  │  │     ├─ firebase_core_plugin_c_api.cpp
   │  │  │  │     ├─ include
   │  │  │  │     │  └─ firebase_core
   │  │  │  │     │     └─ firebase_core_plugin_c_api.h
   │  │  │  │     ├─ messages.g.cpp
   │  │  │  │     ├─ messages.g.h
   │  │  │  │     └─ plugin_version.h.in
   │  │  │  ├─ flutter_secure_storage_windows
   │  │  │  │  ├─ analysis_options.yaml
   │  │  │  │  ├─ CHANGELOG.md
   │  │  │  │  ├─ example
   │  │  │  │  │  ├─ analysis_options.yaml
   │  │  │  │  │  ├─ integration_test
   │  │  │  │  │  │  └─ app_test.dart
   │  │  │  │  │  ├─ lib
   │  │  │  │  │  │  └─ main.dart
   │  │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  │  ├─ README.md
   │  │  │  │  │  └─ windows
   │  │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │  │     ├─ flutter
   │  │  │  │  │     │  ├─ CMakeLists.txt
   │  │  │  │  │     │  ├─ generated_plugins.cmake
   │  │  │  │  │     │  ├─ generated_plugin_registrant.cc
   │  │  │  │  │     │  └─ generated_plugin_registrant.h
   │  │  │  │  │     └─ runner
   │  │  │  │  │        ├─ CMakeLists.txt
   │  │  │  │  │        ├─ flutter_window.cpp
   │  │  │  │  │        ├─ flutter_window.h
   │  │  │  │  │        ├─ main.cpp
   │  │  │  │  │        ├─ resource.h
   │  │  │  │  │        ├─ resources
   │  │  │  │  │        │  └─ app_icon.ico
   │  │  │  │  │        ├─ runner.exe.manifest
   │  │  │  │  │        ├─ Runner.rc
   │  │  │  │  │        ├─ utils.cpp
   │  │  │  │  │        ├─ utils.h
   │  │  │  │  │        ├─ win32_window.cpp
   │  │  │  │  │        └─ win32_window.h
   │  │  │  │  ├─ lib
   │  │  │  │  │  ├─ flutter_secure_storage_windows.dart
   │  │  │  │  │  └─ src
   │  │  │  │  │     ├─ flutter_secure_storage_windows_ffi.dart
   │  │  │  │  │     └─ flutter_secure_storage_windows_stub.dart
   │  │  │  │  ├─ LICENSE
   │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  ├─ README.md
   │  │  │  │  ├─ test
   │  │  │  │  │  └─ unit_test.dart
   │  │  │  │  └─ windows
   │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │     ├─ flutter_secure_storage_windows_plugin.cpp
   │  │  │  │     └─ include
   │  │  │  │        └─ flutter_secure_storage_windows
   │  │  │  │           └─ flutter_secure_storage_windows_plugin.h
   │  │  │  ├─ path_provider_windows
   │  │  │  │  ├─ AUTHORS
   │  │  │  │  ├─ CHANGELOG.md
   │  │  │  │  ├─ example
   │  │  │  │  │  ├─ integration_test
   │  │  │  │  │  │  └─ path_provider_test.dart
   │  │  │  │  │  ├─ lib
   │  │  │  │  │  │  └─ main.dart
   │  │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  │  ├─ README.md
   │  │  │  │  │  ├─ test_driver
   │  │  │  │  │  │  └─ integration_test.dart
   │  │  │  │  │  └─ windows
   │  │  │  │  │     ├─ CMakeLists.txt
   │  │  │  │  │     ├─ flutter
   │  │  │  │  │     │  ├─ CMakeLists.txt
   │  │  │  │  │     │  └─ generated_plugins.cmake
   │  │  │  │  │     └─ runner
   │  │  │  │  │        ├─ CMakeLists.txt
   │  │  │  │  │        ├─ flutter_window.cpp
   │  │  │  │  │        ├─ flutter_window.h
   │  │  │  │  │        ├─ main.cpp
   │  │  │  │  │        ├─ resource.h
   │  │  │  │  │        ├─ resources
   │  │  │  │  │        │  └─ app_icon.ico
   │  │  │  │  │        ├─ runner.exe.manifest
   │  │  │  │  │        ├─ Runner.rc
   │  │  │  │  │        ├─ run_loop.cpp
   │  │  │  │  │        ├─ run_loop.h
   │  │  │  │  │        ├─ utils.cpp
   │  │  │  │  │        ├─ utils.h
   │  │  │  │  │        ├─ win32_window.cpp
   │  │  │  │  │        └─ win32_window.h
   │  │  │  │  ├─ lib
   │  │  │  │  │  ├─ path_provider_windows.dart
   │  │  │  │  │  └─ src
   │  │  │  │  │     ├─ folders.dart
   │  │  │  │  │     ├─ folders_stub.dart
   │  │  │  │  │     ├─ guid.dart
   │  │  │  │  │     ├─ path_provider_windows_real.dart
   │  │  │  │  │     ├─ path_provider_windows_stub.dart
   │  │  │  │  │     └─ win32_wrappers.dart
   │  │  │  │  ├─ LICENSE
   │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  ├─ README.md
   │  │  │  │  └─ test
   │  │  │  │     ├─ guid_test.dart
   │  │  │  │     └─ path_provider_windows_test.dart
   │  │  │  └─ permission_handler_windows
   │  │  │     ├─ AUTHORS
   │  │  │     ├─ CHANGELOG.md
   │  │  │     ├─ example
   │  │  │     │  ├─ lib
   │  │  │     │  │  └─ main.dart
   │  │  │     │  ├─ pubspec.yaml
   │  │  │     │  ├─ README.md
   │  │  │     │  ├─ res
   │  │  │     │  │  └─ images
   │  │  │     │  │     ├─ baseflow_logo_def_light-02.png
   │  │  │     │  │     ├─ poweredByBaseflowLogoLight.png
   │  │  │     │  │     ├─ poweredByBaseflowLogoLight@2x.png
   │  │  │     │  │     └─ poweredByBaseflowLogoLight@3x.png
   │  │  │     │  └─ windows
   │  │  │     │     ├─ CMakeLists.txt
   │  │  │     │     ├─ flutter
   │  │  │     │     │  ├─ CMakeLists.txt
   │  │  │     │     │  ├─ generated_plugins.cmake
   │  │  │     │     │  ├─ generated_plugin_registrant.cc
   │  │  │     │     │  └─ generated_plugin_registrant.h
   │  │  │     │     └─ runner
   │  │  │     │        ├─ CMakeLists.txt
   │  │  │     │        ├─ flutter_window.cpp
   │  │  │     │        ├─ flutter_window.h
   │  │  │     │        ├─ main.cpp
   │  │  │     │        ├─ resource.h
   │  │  │     │        ├─ resources
   │  │  │     │        │  └─ app_icon.ico
   │  │  │     │        ├─ runner.exe.manifest
   │  │  │     │        ├─ Runner.rc
   │  │  │     │        ├─ utils.cpp
   │  │  │     │        ├─ utils.h
   │  │  │     │        ├─ win32_window.cpp
   │  │  │     │        └─ win32_window.h
   │  │  │     ├─ LICENSE
   │  │  │     ├─ pubspec.yaml
   │  │  │     ├─ README.md
   │  │  │     └─ windows
   │  │  │        ├─ CMakeLists.txt
   │  │  │        ├─ include
   │  │  │        │  └─ permission_handler_windows
   │  │  │        │     └─ permission_handler_windows_plugin.h
   │  │  │        ├─ permission_constants.h
   │  │  │        └─ permission_handler_windows_plugin.cpp
   │  │  ├─ cpp_client_wrapper
   │  │  │  ├─ binary_messenger_impl.h
   │  │  │  ├─ byte_buffer_streams.h
   │  │  │  ├─ core_implementations.cc
   │  │  │  ├─ engine_method_result.cc
   │  │  │  ├─ flutter_engine.cc
   │  │  │  ├─ flutter_view_controller.cc
   │  │  │  ├─ include
   │  │  │  │  └─ flutter
   │  │  │  │     ├─ basic_message_channel.h
   │  │  │  │     ├─ binary_messenger.h
   │  │  │  │     ├─ byte_streams.h
   │  │  │  │     ├─ dart_project.h
   │  │  │  │     ├─ encodable_value.h
   │  │  │  │     ├─ engine_method_result.h
   │  │  │  │     ├─ event_channel.h
   │  │  │  │     ├─ event_sink.h
   │  │  │  │     ├─ event_stream_handler.h
   │  │  │  │     ├─ event_stream_handler_functions.h
   │  │  │  │     ├─ flutter_engine.h
   │  │  │  │     ├─ flutter_view.h
   │  │  │  │     ├─ flutter_view_controller.h
   │  │  │  │     ├─ message_codec.h
   │  │  │  │     ├─ method_call.h
   │  │  │  │     ├─ method_channel.h
   │  │  │  │     ├─ method_codec.h
   │  │  │  │     ├─ method_result.h
   │  │  │  │     ├─ method_result_functions.h
   │  │  │  │     ├─ plugin_registrar.h
   │  │  │  │     ├─ plugin_registrar_windows.h
   │  │  │  │     ├─ plugin_registry.h
   │  │  │  │     ├─ standard_codec_serializer.h
   │  │  │  │     ├─ standard_message_codec.h
   │  │  │  │     ├─ standard_method_codec.h
   │  │  │  │     └─ texture_registrar.h
   │  │  │  ├─ plugin_registrar.cc
   │  │  │  ├─ README
   │  │  │  ├─ standard_codec.cc
   │  │  │  └─ texture_registrar_impl.h
   │  │  ├─ flutter_export.h
   │  │  ├─ flutter_messenger.h
   │  │  ├─ flutter_plugin_registrar.h
   │  │  ├─ flutter_texture_registrar.h
   │  │  ├─ flutter_windows.dll
   │  │  ├─ flutter_windows.dll.exp
   │  │  ├─ flutter_windows.dll.lib
   │  │  ├─ flutter_windows.dll.pdb
   │  │  ├─ flutter_windows.h
   │  │  ├─ generated_config.cmake
   │  │  └─ icudtl.dat
   │  ├─ generated_plugins.cmake
   │  ├─ generated_plugin_registrant.cc
   │  └─ generated_plugin_registrant.h
   └─ runner
      ├─ CMakeLists.txt
      ├─ flutter_window.cpp
      ├─ flutter_window.h
      ├─ main.cpp
      ├─ resource.h
      ├─ resources
      │  └─ app_icon.ico
      ├─ runner.exe.manifest
      ├─ Runner.rc
      ├─ utils.cpp
      ├─ utils.h
      ├─ win32_window.cpp
      └─ win32_window.h

```