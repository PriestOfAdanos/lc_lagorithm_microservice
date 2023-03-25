cmake_minimum_required(VERSION 3.10)

project(Microservice)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O2")
set(CMAKE_CXX_FLAGS "-Wall -Wextra -pthread")

find_package(Boost REQUIRED COMPONENTS filesystem system)
find_package(PCL REQUIRED COMPONENTS common io surface search kdtree)

include_directories(${Boost_INCLUDE_DIRS} ${PCL_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS} ${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})

add_executable(microservice microservice.cpp)

target_link_libraries(microservice
                      PRIVATE
                      ${Boost_LIBRARIES}
                      ${PCL_COMMON_LIBRARIES}
                      ${PCL_IO_LIBRARIES}
                      ${PCL_SURFACE_LIBRARIES}
                      ${PCL_SEARCH_LIBRARIES}
                      ${PCL_KDTREE_LIBRARIES})