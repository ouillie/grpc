"""
Rules that provide both a standard executable and gRPC plugin options.

The C++ and Objective-C gRPC generator rules historically allowed
overriding the gRPC plugin by passing a simple executable attribute.

The new gRPC plugin toolchains allow specifying Protobuf plugin options
(passed as e.g. `--<plugin>_opt=foo,bar,baz`) while registering toolchains.

In order to support both the legacy, simple-executable overrides
while also supporting the newer executable-plus-options toolchains,
we define rules which provide both,
and rely on the generator rule implementations
to gracefully fall back to the legacy behavior if needed.
"""

load("//bazel/toolchains:plugins.bzl", "GrpcPluginInfo")

def _executable_plugin_from_toolchain(toolchain_type):
    """
    Return a executable rule that exposes the plugin binary for `toolchain_type`,
    as well as providing the `GrpcPluginInfo` for the resolved toolchain.
    """

    def _impl(ctx):
        plugin_info = ctx.toolchains[toolchain_type].plugin

        # An executable rule must produce a new executable file,
        # so symlink to the toolchain-provided binary.
        ctx.actions.symlink(
            output = ctx.outputs.executable,
            target_file = plugin_info.bin,
            is_executable = True,
        )

        return [
            DefaultInfo(
                files = depset([ctx.outputs.executable]),
                executable = ctx.outputs.executable,
                runfiles = plugin_info.runfiles,
            ),
            plugin_info,
        ]

    return rule(
        implementation = _impl,
        executable = True,
        toolchains = [toolchain_type],
    )

cpp_executable_plugin_from_toolchain = _executable_plugin_from_toolchain(Label("//bazel/toolchains:grpc_cpp_plugin_toolchain_type"))
objc_executable_plugin_from_toolchain = _executable_plugin_from_toolchain(Label("//bazel/toolchains:grpc_objective_c_plugin_toolchain_type"))
python_executable_plugin_from_toolchain = _executable_plugin_from_toolchain(Label("//bazel/toolchains:grpc_python_plugin_toolchain_type"))

def _executable_plugin_from_source(binary):
    """
    Return a executable rule that exposes the labeled binary
    as well as providing a dummy `GrpcPluginInfo` with the same binary
    and no options.
    """

    def _impl(ctx):
        runfiles = ctx.attr._binary[DefaultInfo].default_runfiles

        # An executable rule must produce a new executable file,
        # so symlink to the labeled binary.
        ctx.actions.symlink(
            output = ctx.outputs.executable,
            target_file = ctx.executable._binary,
            is_executable = True,
        )

        return [
            DefaultInfo(
                files = depset([ctx.outputs.executable]),
                executable = ctx.outputs.executable,
                runfiles = runfiles,
            ),
            GrpcPluginInfo(
                bin = ctx.executable._binary,
                options = [],
                runfiles = runfiles,
            ),
        ]

    return rule(
        implementation = _impl,
        executable = True,
        attrs = {
            "_binary": attr.label(
                default = binary,
                executable = True,
                cfg = "exec",
            ),
        },
    )

cpp_executable_plugin_from_source = _executable_plugin_from_source(Label("//src/compiler:grpc_cpp_plugin"))
objc_executable_plugin_from_source = _executable_plugin_from_source(Label("//src/compiler:grpc_objective_c_plugin"))
python_executable_plugin_from_source = _executable_plugin_from_source(Label("//src/compiler:grpc_python_plugin"))
