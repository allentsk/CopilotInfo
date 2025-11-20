cmake_minimum_required(VERSION 3.24)
project(MidiRouter VERSION 0.10.48 LANGUAGES C CXX OBJCXX)

# --- macOS toolchain
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "" FORCE)
set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0" CACHE STRING "" FORCE)
#set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(JUCE CONFIG REQUIRED)

# --- App target (explicit sources from your folders)
add_executable(MidiRouter MACOSX_BUNDLE
    Source/config/Config.cpp
    Source/config/Config.h
    Source/controller/MidiConfig/MidiConfigImpl.cpp
    Source/controller/MidiConfig/MidiConfigImpl.h
    Source/controller/app/Main.cpp
    Source/controller/app/MainComponent.cpp
    Source/controller/app/MainComponent.h
    Source/controller/core/Logger.h
    Source/controller/core/SerializationManager.cpp
    Source/controller/core/SerializationManager.h
    Source/controller/system/SystemTheme.mm
    Source/controller/theme/Theme.cpp
    Source/controller/theme/Theme.h
    Source/model/DisplayNameValidator.cpp
    Source/model/DisplayNameValidator.hpp
    Source/model/MidiPort.cpp
    Source/model/MidiPort.hpp
    Source/model/MidiPorts.cpp
    Source/model/MidiPorts.hpp
    Source/view/CustomTabLookAndFeel.cpp
    Source/view/CustomTabLookAndFeel.h
    Source/view/Dante.cpp
    Source/view/Dante.h
    Source/view/IOMatrix.cpp
    Source/view/IOMatrix.h
    Source/view/MidiConfig.cpp
    Source/view/MidiConfig.h
    Source/view/Novation.cpp
    Source/view/Novation.h
    Source/view/Status.cpp
    Source/view/Status.h
)

# If SystemTheme.mm uses Cocoa APIs, enable ARC (optional but typical)
set_source_files_properties(Source/system/SystemTheme.mm
    PROPERTIES COMPILE_FLAGS "-fobjc-arc")

# Nice IDE grouping
source_group(TREE ${CMAKE_SOURCE_DIR}/Source PREFIX "Source" FILES
    Source/config/Config.cpp
    Source/config/Config.h
    Source/controller/MidiConfig/MidiConfigImpl.cpp
    Source/controller/MidiConfig/MidiConfigImpl.h
    Source/controller/app/Main.cpp
    Source/controller/app/MainComponent.cpp
    Source/controller/app/MainComponent.h
    Source/controller/core/Logger.h
    Source/controller/core/SerializationManager.cpp
    Source/controller/core/SerializationManager.h
    Source/controller/system/SystemTheme.mm
    Source/controller/theme/Theme.cpp
    Source/controller/theme/Theme.h
    Source/model/DisplayNameValidator.cpp
    Source/model/DisplayNameValidator.hpp
    Source/model/MidiPort.cpp
    Source/model/MidiPort.hpp
    Source/model/MidiPorts.cpp
    Source/model/MidiPorts.hpp
    Source/view/CustomTabLookAndFeel.cpp
    Source/view/CustomTabLookAndFeel.h
    Source/view/Dante.cpp
    Source/view/Dante.h
    Source/view/IOMatrix.cpp
    Source/view/IOMatrix.h
    Source/view/MidiConfig.cpp
    Source/view/MidiConfig.h
    Source/view/Novation.cpp
    Source/view/Novation.h
    Source/view/Status.cpp
    Source/view/Status.h
)

configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/ProjectInfo.h.in
    ${CMAKE_BINARY_DIR}/generated/ProjectInfo.h
    @ONLY
)

# Add per Copilot 10/13/25
# Include the generated ProjectInfo.h directory
target_include_directories(MidiRouter PRIVATE ${CMAKE_BINARY_DIR}/generated)

# ARS 10/18 Add Source directories to remove relative in source includes
target_include_directories(MidiRouter PRIVATE ${CMAKE_SOURCE_DIR}/Source)

# JUCE modules you actually use
target_link_libraries(MidiRouter PRIVATE
    juce::juce_gui_basics
    juce::juce_gui_extra
    juce::juce_graphics
    juce::juce_audio_devices
    juce::juce_audio_basics
    juce::juce_core
)

# ---- External deps ----
# ---- cereal
# cereal (header-only; use find_path to locate its includes)
find_path(CEREAL_INCLUDE_DIR "cereal/cereal.hpp" HINTS /opt/homebrew/include)
if (NOT CEREAL_INCLUDE_DIR)
    message(FATAL_ERROR "cereal headers not found. Please install cereal or ensure it's in external/cereal")
endif()
target_include_directories(MidiRouter PRIVATE ${CEREAL_INCLUDE_DIR})


# ---- fmt (Homebrew provides a CMake package)
find_package(fmt CONFIG REQUIRED)
target_link_libraries(MidiRouter PRIVATE fmt::fmt-header-only)

# ---- toml++ (header-only; use find_path to locate its includes)
find_path(TOMLPLUSPLUS_INCLUDE_DIR "toml++/toml.h" HINTS /opt/homebrew/include)
if (NOT TOMLPLUSPLUS_INCLUDE_DIR)
    message(FATAL_ERROR "toml++ headers not found. Try: brew install tomlplusplus")
endif()
target_include_directories(MidiRouter PRIVATE ${TOMLPLUSPLUS_INCLUDE_DIR})


# Default to Debug if no config chosen (handy for Ninja)
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Make app version available in code
target_compile_definitions(MidiRouter PRIVATE JUCE_APP_VERSION="${PROJECT_VERSION}")

# Apple/Ubuntu block
if(APPLE)
   message("** Apple configuration **")
   # Bundle ID and versions (populate Info.plist automatically)
   set(BUNDLE_ID "com.thestrands.midirouter")
   set(BUILD_NUMBER "${PROJECT_VERSION_MAJOR}${PROJECT_VERSION_MINOR}${PROJECT_VERSION_PATCH}")
   
   set_target_properties(MidiRouter PROPERTIES
       XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${BUNDLE_ID}"
       MACOSX_BUNDLE_SHORT_VERSION_STRING       "${PROJECT_VERSION}"  # CFBundleShortVersionString
       MACOSX_BUNDLE_BUNDLE_VERSION             "${BUILD_NUMBER}"     # CFBundleVersion
       MACOSX_BUNDLE TRUE

   # Optional install target (stages the .app on `--target install`)
   include(GNUInstallDirs)
   install(TARGETS MidiRouter BUNDLE DESTINATION .)

   # Optional: use your own Info-App.plist template if you keep one
   # set_target_properties(MidiRouter PROPERTIES
   #     MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/cmake/Info-App.plist"
   # )

   # Optional: Add custom code-signing step if desired
   # add_custom_command(TARGET MidiRouter POST_BUILD
   #     COMMAND codesign --force --deep --sign "Developer ID Application: Your Name" "$<TARGET_BUNDLE_DIR:MidiRouter>"
   # )
   )
else()
   message("** ubuntu configuration **")

    # --- Non-macOS defaults ---
    # Do not set bundle, info.plist, or macOS-specific install
    # Create standard executable, possibly with a generic install rule
    install(TARGETS MidiRouter DESTINATION bin)
endif()
