cmake_minimum_required(VERSION 3.8)
project(certify VERSION 0.1 LANGUAGES CXX)

list(INSERT CMAKE_MODULE_PATH 0 ${PROJECT_SOURCE_DIR}/CMakeModules)

if (CMAKE_VERSION VERSION_LESS 3.11)
    # Latest FindBoost.cmake has likely been updated to detect Boost version not yet released
    if (NOT EXISTS "${CMAKE_BINARY_DIR}/cmake/FindBoost.cmake")
        message(STATUS "Downloading FindBoost.cmake from https://gitlab.kitware.com/cmake/ release branch")
        file(
            DOWNLOAD
            "https://gitlab.kitware.com/cmake/cmake/raw/release/Modules/FindBoost.cmake"
            "${CMAKE_BINARY_DIR}/cmake/FindBoost.cmake")
    endif()
    list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_BINARY_DIR}/cmake)
endif()

find_package(Boost 1.67
             COMPONENTS
                system
                filesystem
                date_time
                unit_test_framework
             REQUIRED)

find_package (Threads)

find_package(OpenSSL REQUIRED)


add_library(core INTERFACE)

add_library(certify::core ALIAS core)

target_compile_features(core INTERFACE cxx_std_11)

target_include_directories(core INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if(MSVC)
	target_link_libraries(core INTERFACE Crypt32.lib)
endif()

if (APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(SECURITY_LIBRARY Security)
    target_link_libraries(core INTERFACE ${COREFOUNDATION_LIBRARY} ${SECURITY_LIBRARY})
endif ()

target_link_libraries(
    core
    INTERFACE
        Boost::system
        Boost::filesystem
        Boost::date_time
        Threads::Threads
        OpenSSL::SSL
        OpenSSL::Crypto)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/certifyConfigVersion.cmake"
    COMPATIBILITY AnyNewerVersion)

install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/certifyConfig.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/certifyConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/certify)

install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
	FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")

install(TARGETS core
        EXPORT certifyTargets
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT certifyTargets
        FILE certifyTargets.cmake
        NAMESPACE certify::
        DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/certify)

include(CTest)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
