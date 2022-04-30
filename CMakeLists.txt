cmake_minimum_required(VERSION 3.6)
set(CMAKE_CXX_STANDARD 17)

project(project LANGUAGES CXX)

find_package(aws-lambda-runtime)
# find_package(AWSSDK COMPONENTS logs)

add_executable(
    ${PROJECT_NAME}
    "src/main.cpp"
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR})

target_link_libraries(${PROJECT_NAME} PRIVATE AWS::aws-lambda-runtime)
# target_link_libraries(${PROJECT_NAME} PRIVATE ${AWSSDK_LINK_LIBRARIES})

target_compile_features(${PROJECT_NAME} PRIVATE "cxx_std_17")
target_compile_options(${PROJECT_NAME} PRIVATE "-O3" "-Wall" "-Wextra")

# this line creates a target that packages your binary and zips it up
aws_lambda_package_target(${PROJECT_NAME})
