# flutter_client

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

```

```
flutter_client
├─ .gitignore
├─ .metadata
├─ analysis_options.yaml
├─ android
│  ├─ .gitignore
│  ├─ app
│  │  ├─ build.gradle
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
│  │     │  │        └─ flutter_client
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
│  └─ Runner.xcworkspace
│     ├─ contents.xcworkspacedata
│     └─ xcshareddata
│        ├─ IDEWorkspaceChecks.plist
│        └─ WorkspaceSettings.xcsettings
├─ lib
│  ├─ app
│  │  ├─ controllers
│  │  │  ├─ auth_controller.dart
│  │  │  ├─ controller_provider.dart
│  │  │  ├─ home_controller.dart
│  │  │  ├─ navigation_controller.dart
│  │  │  ├─ order_controller.dart
│  │  │  ├─ order_queue_controller.dart
│  │  │  ├─ quick_order_queue_controller.dart
│  │  │  ├─ sales_controller.dart
│  │  │  ├─ sidebar_controller.dart
│  │  │  └─ table_controller.dart
│  │  ├─ data
│  │  │  ├─ models
│  │  │  │  ├─ daily_sales.dart
│  │  │  │  ├─ menu.dart
│  │  │  │  ├─ models.dart
│  │  │  │  ├─ order.dart
│  │  │  │  ├─ restaurant.dart
│  │  │  │  └─ table_model.dart
│  │  │  ├─ providers
│  │  │  │  ├─ api_provider.dart
│  │  │  │  ├─ auth_api.dart
│  │  │  │  └─ order_api.dart
│  │  │  └─ services
│  │  │     └─ socket_service.dart
│  │  ├─ middleware
│  │  │  └─ auth_middleware.dart
│  │  ├─ modules
│  │  │  ├─ admin
│  │  │  │  ├─ admin_binding.dart
│  │  │  │  ├─ admin_controller.dart
│  │  │  │  ├─ admin_layout.dart
│  │  │  │  ├─ admin_order
│  │  │  │  │  ├─ admin_order_binding.dart
│  │  │  │  │  ├─ admin_order_controller.dart
│  │  │  │  │  └─ admin_order_view.dart
│  │  │  │  ├─ dashboard
│  │  │  │  │  ├─ dashboard_binding.dart
│  │  │  │  │  └─ dashboard_view.dart
│  │  │  │  ├─ edit_menu
│  │  │  │  │  ├─ edit_menu_binding.dart
│  │  │  │  │  ├─ edit_menu_controller.dart
│  │  │  │  │  └─ edit_menu_view.dart
│  │  │  │  ├─ menu
│  │  │  │  │  └─ menu_view.dart
│  │  │  │  ├─ payments
│  │  │  │  │  ├─ payments_binding.dart
│  │  │  │  │  ├─ payments_controller.dart
│  │  │  │  │  └─ payments_view.dart
│  │  │  │  ├─ profile
│  │  │  │  │  ├─ profile_binding.dart
│  │  │  │  │  ├─ profile_controller.dart
│  │  │  │  │  └─ profile_view.dart
│  │  │  │  ├─ qr_generate
│  │  │  │  │  ├─ qr_generate_binding.dart
│  │  │  │  │  ├─ qr_generate_controller.dart
│  │  │  │  │  └─ qr_generate_view.dart
│  │  │  │  ├─ quick_order
│  │  │  │  │  ├─ quick_order_binding.dart
│  │  │  │  │  ├─ quick_order_controller.dart
│  │  │  │  │  └─ quick_order_view.dart
│  │  │  │  ├─ sales
│  │  │  │  │  ├─ sales_binding.dart
│  │  │  │  │  ├─ sales_controller.dart
│  │  │  │  │  └─ sales_view.dart
│  │  │  │  └─ table_edit
│  │  │  │     └─ table_edit_view.dart
│  │  │  ├─ auth
│  │  │  │  ├─ login
│  │  │  │  │  ├─ login_binding.dart
│  │  │  │  │  ├─ login_controller.dart
│  │  │  │  │  └─ login_view.dart
│  │  │  │  └─ register
│  │  │  │     ├─ register_binding.dart
│  │  │  │     ├─ register_controller.dart
│  │  │  │     └─ register_view.dart
│  │  │  ├─ components
│  │  │  │  └─ nav
│  │  │  │     ├─ side_nav.dart
│  │  │  │     └─ top_bar.dart
│  │  │  └─ home
│  │  │     ├─ home_binding.dart
│  │  │     └─ home_view.dart
│  │  ├─ routes
│  │  │  ├─ app_pages.dart
│  │  │  └─ app_routes.dart
│  │  └─ ui
│  │     ├─ theme
│  │     │  ├─ app_colors.dart
│  │     │  ├─ app_text_styles.dart
│  │     │  └─ app_theme.dart
│  │     └─ widgets
│  │        ├─ advanced_table_layout.dart
│  │        ├─ cart.dart
│  │        ├─ loading_spinner.dart
│  │        ├─ menu_form.dart
│  │        ├─ menu_list.dart
│  │        ├─ restaurant_table.dart
│  │        └─ tab_component.dart
│  ├─ core
│  │  ├─ utils
│  │  └─ values
│  │     └─ env.dart
│  └─ main.dart
├─ linux
│  ├─ .gitignore
│  ├─ CMakeLists.txt
│  ├─ flutter
│  │  ├─ CMakeLists.txt
│  │  ├─ ephemeral
│  │  │  └─ .plugin_symlinks
│  │  │     ├─ path_provider_linux
│  │  │     │  ├─ AUTHORS
│  │  │     │  ├─ CHANGELOG.md
│  │  │     │  ├─ example
│  │  │     │  │  ├─ integration_test
│  │  │     │  │  │  └─ path_provider_test.dart
│  │  │     │  │  ├─ lib
│  │  │     │  │  │  └─ main.dart
│  │  │     │  │  ├─ linux
│  │  │     │  │  │  ├─ CMakeLists.txt
│  │  │     │  │  │  ├─ flutter
│  │  │     │  │  │  │  ├─ CMakeLists.txt
│  │  │     │  │  │  │  └─ generated_plugins.cmake
│  │  │     │  │  │  ├─ main.cc
│  │  │     │  │  │  ├─ my_application.cc
│  │  │     │  │  │  └─ my_application.h
│  │  │     │  │  ├─ pubspec.yaml
│  │  │     │  │  ├─ README.md
│  │  │     │  │  └─ test_driver
│  │  │     │  │     └─ integration_test.dart
│  │  │     │  ├─ lib
│  │  │     │  │  ├─ path_provider_linux.dart
│  │  │     │  │  └─ src
│  │  │     │  │     ├─ get_application_id.dart
│  │  │     │  │     ├─ get_application_id_real.dart
│  │  │     │  │     ├─ get_application_id_stub.dart
│  │  │     │  │     └─ path_provider_linux.dart
│  │  │     │  ├─ LICENSE
│  │  │     │  ├─ pubspec.yaml
│  │  │     │  ├─ README.md
│  │  │     │  └─ test
│  │  │     │     ├─ get_application_id_test.dart
│  │  │     │     └─ path_provider_linux_test.dart
│  │  │     └─ shared_preferences_linux
│  │  │        ├─ AUTHORS
│  │  │        ├─ CHANGELOG.md
│  │  │        ├─ example
│  │  │        │  ├─ integration_test
│  │  │        │  │  └─ shared_preferences_test.dart
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
│  │  │        │  └─ shared_preferences_linux.dart
│  │  │        ├─ LICENSE
│  │  │        ├─ pubspec.yaml
│  │  │        ├─ README.md
│  │  │        └─ test
│  │  │           └─ shared_preferences_linux_test.dart
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
│  └─ Runner.xcworkspace
│     ├─ contents.xcworkspacedata
│     └─ xcshareddata
│        └─ IDEWorkspaceChecks.plist
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
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
   │  │  │  │  │     ├─ path_provider_windows_real.dart
   │  │  │  │  │     └─ path_provider_windows_stub.dart
   │  │  │  │  ├─ LICENSE
   │  │  │  │  ├─ pubspec.yaml
   │  │  │  │  ├─ README.md
   │  │  │  │  └─ test
   │  │  │  │     └─ path_provider_windows_test.dart
   │  │  │  └─ shared_preferences_windows
   │  │  │     ├─ AUTHORS
   │  │  │     ├─ CHANGELOG.md
   │  │  │     ├─ example
   │  │  │     │  ├─ AUTHORS
   │  │  │     │  ├─ integration_test
   │  │  │     │  │  └─ shared_preferences_test.dart
   │  │  │     │  ├─ lib
   │  │  │     │  │  └─ main.dart
   │  │  │     │  ├─ LICENSE
   │  │  │     │  ├─ pubspec.yaml
   │  │  │     │  ├─ README.md
   │  │  │     │  ├─ test_driver
   │  │  │     │  │  └─ integration_test.dart
   │  │  │     │  └─ windows
   │  │  │     │     ├─ CMakeLists.txt
   │  │  │     │     ├─ flutter
   │  │  │     │     │  ├─ CMakeLists.txt
   │  │  │     │     │  └─ generated_plugins.cmake
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
   │  │  │     │        ├─ run_loop.cpp
   │  │  │     │        ├─ run_loop.h
   │  │  │     │        ├─ utils.cpp
   │  │  │     │        ├─ utils.h
   │  │  │     │        ├─ win32_window.cpp
   │  │  │     │        └─ win32_window.h
   │  │  │     ├─ lib
   │  │  │     │  └─ shared_preferences_windows.dart
   │  │  │     ├─ LICENSE
   │  │  │     ├─ pubspec.yaml
   │  │  │     ├─ README.md
   │  │  │     └─ test
   │  │  │        └─ shared_preferences_windows_test.dart
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
