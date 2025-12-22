# Copyright 2026 The gRPC Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load(
    ":executable_plugin.bzl",
    "cpp_executable_plugin_from_source",
    "cpp_executable_plugin_from_toolchain",
    "objc_executable_plugin_from_source",
    "objc_executable_plugin_from_toolchain",
    "python_executable_plugin_from_source",
    "python_executable_plugin_from_toolchain",
)

config_setting(
    name = "grpc_plugin_toolchain_resolution_enabled",
    flag_values = {
        "//bazel/toolchains:enable_grpc_plugin_toolchain_resolution": "true",
    },
)

alias(
    name = "resolved_grpc_cpp_plugin",
    actual = select({
        ":grpc_plugin_toolchain_resolution_enabled": ":cpp_executable_plugin_from_toolchain",
        "//conditions:default": ":cpp_executable_plugin_from_source",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "resolved_grpc_objective_c_plugin",
    actual = select({
        ":grpc_plugin_toolchain_resolution_enabled": ":objc_executable_plugin_from_toolchain",
        "//conditions:default": ":objc_executable_plugin_from_source",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "resolved_grpc_python_plugin",
    actual = select({
        ":grpc_plugin_toolchain_resolution_enabled": ":python_executable_plugin_from_toolchain",
        "//conditions:default": ":python_executable_plugin_from_source",
    }),
    visibility = ["//visibility:public"],
)

cpp_executable_plugin_from_source(name = "cpp_executable_plugin_from_source")
cpp_executable_plugin_from_toolchain(name = "cpp_executable_plugin_from_toolchain")
objc_executable_plugin_from_source(name = "objc_executable_plugin_from_source")
objc_executable_plugin_from_toolchain(name = "objc_executable_plugin_from_toolchain")
python_executable_plugin_from_source(name = "python_executable_plugin_from_source")
python_executable_plugin_from_toolchain(name = "python_executable_plugin_from_toolchain")
