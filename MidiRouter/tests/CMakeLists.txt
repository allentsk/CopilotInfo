cmake_minimum_required(VERSION 3.16)
project(MidiRouterTests LANGUAGES C CXX)

# --- Testing ---
enable_testing()

# Paths (tests/ is current dir; repo root is one up)
set(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")

# Dependencies from /usr/local (JUCE & fmt via your install)
set(CMAKE_PREFIX_PATH "/usr/local")

# fmt: use header-only to avoid runtime dylib headaches in Xcode
set(CMAKE_PREFIX_PATH "/Users/allen/StrandsKitchen/github/juce/cmake-build/lib/cmake/JUCE-8.0.10")
find_package(fmt CONFIG REQUIRED)

# JUCE core/graphics/events are enough for Theme/Config
find_package(JUCE CONFIG REQUIRED)

# GoogleTest (fetch locally for a stable, reproducible build)
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# ---- Target ---------------------------------------------------------------------------------------
add_executable(MidiRouterTests
  ${REPO_ROOT}/Source/controller/theme/Theme.cpp
  ${REPO_ROOT}/Source/config/Config.cpp    # you test Config too
  # GUI components for testing
  ${REPO_ROOT}/Source/view/CustomTabLookAndFeel.cpp
  ${REPO_ROOT}/Source/view/MidiConfig.cpp
  ${REPO_ROOT}/Source/view/IOMatrix.cpp
  ${REPO_ROOT}/Source/view/Novation.cpp
  ${REPO_ROOT}/Source/view/Dante.cpp
  ${REPO_ROOT}/Source/view/Status.cpp
  # Model components for testing
  ${REPO_ROOT}/Source/model/MidiPort.cpp
  ${REPO_ROOT}/Source/model/MidiPorts.cpp
  ${REPO_ROOT}/Source/model/DisplayNameValidator.cpp
  ${REPO_ROOT}/Source/controller/MidiConfig/MidiConfigImpl.cpp
  ${REPO_ROOT}/Source/controller/core/SerializationManager.cpp
  ${REPO_ROOT}/tests/tests_theme_and_config.cpp
  ${REPO_ROOT}/tests/test_main_component.cpp
  # GUI component tests
  ${REPO_ROOT}/tests/view/test_midi_config.cpp
  ${REPO_ROOT}/tests/view/test_io_matrix.cpp
  ${REPO_ROOT}/tests/view/test_novation.cpp
  ${REPO_ROOT}/tests/view/test_dante.cpp
  ${REPO_ROOT}/tests/view/test_status.cpp
  # Model tests
  ${REPO_ROOT}/tests/model/test_display_name_validator.cpp
  ${REPO_ROOT}/tests/model/test_midi_ports.cpp
  ${REPO_ROOT}/tests/controller/MidiConfig/test_midi_config_impl.cpp
  ${REPO_ROOT}/tests/controller/core/test_serialization_manager.cpp
)

# --- Commmenting out copilot generated code until corrected 
# set_source_files_properties(
#   ${REPO_ROOT}/tests/model/test_display_name_validator.cpp
#   PROPERTIES COMPILE_DEFINITIONS SKIP_TEST
# )

target_include_directories(MidiRouterTests PRIVATE
  ${REPO_ROOT}/Source
  ${REPO_ROOT}/Source/config
  ${REPO_ROOT}/Source/core
  ${REPO_ROOT}/Source/model
  ${REPO_ROOT}/Source/theme
  ${REPO_ROOT}/Source/view
  #${REPO_ROOT}/external/cereal/include
  /usr/local/include/JUCE-8.0.10/modules     # JUCE headers
  /opt/homebrew/include                      # Homebrew headers (spdlog/fmt if needed)
)

target_compile_features(MidiRouterTests PRIVATE cxx_std_17)

target_link_libraries(MidiRouterTests PRIVATE
  GTest::gtest_main        # ← only this (no plain GTest::gtest)
  juce::juce_core
  juce::juce_graphics
  juce::juce_gui_basics
  juce::juce_events
  juce::juce_gui_extra
  juce::juce_audio_basics
  juce::juce_audio_devices
  fmt::fmt-header-only     # header-only to avoid dylib runtime oddities
)

# Register the test binary for ctest everywhere
add_test(NAME MidiRouterTests COMMAND MidiRouterTests)

include(GoogleTest)

if (CMAKE_GENERATOR STREQUAL "Xcode")
  # Xcode: DO NOT run the test exe during the build (post-build script).
  # Provide a helper target you can build to run tests via ctest.
  add_custom_target(RunTests
    COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIG> --output-on-failure
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS MidiRouterTests
  )

  # (Optional) silence duplicate-lib warning and codesign fuss for the console exe
  set_target_properties(MidiRouterTests PROPERTIES
    XCODE_ATTRIBUTE_OTHER_LDFLAGS "-Wl,-no_warn_duplicate_libraries"
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
    XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
    XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME "NO"
  )
else()
  # Non-Xcode: discover tests at test time (not build time)
  gtest_discover_tests(MidiRouterTests
    DISCOVERY_MODE PRE_TEST
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DISCOVERY_TIMEOUT 30
  )
endif()

