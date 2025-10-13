include(CMakeFindDependencyMacro)

find_dependency(Boost COMPONENTS filesystem date_time)
find_dependency(OpenSSL)
find_dependency(Threads)

include("${CMAKE_CURRENT_LIST_DIR}/certifyTargets.cmake")
