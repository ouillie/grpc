"""Re-exposes the toolchain-resolved protoc as a plain executable.

This mirrors the trick in @grpc//bazel/private:executable_plugin.bzl: consume a
toolchain and symlink its executable into an ordinary `executable` target. It
lets the dummy plugin invoke protoc without hardcoding a platform-specific
prebuilt repo -- protoc is resolved for the exec platform via the proto
toolchain (prebuilt here, never built from source).
"""

_PROTO_TOOLCHAIN = Label("@protobuf//bazel/private:proto_toolchain_type")

def _resolved_protoc_impl(ctx):
    protoc = ctx.toolchains[_PROTO_TOOLCHAIN].proto.proto_compiler

    # An executable rule must produce its own executable, so symlink to protoc.
    ctx.actions.symlink(
        output = ctx.outputs.executable,
        target_file = protoc.executable,
        is_executable = True,
    )
    return [DefaultInfo(
        files = depset([ctx.outputs.executable]),
        executable = ctx.outputs.executable,
    )]

resolved_protoc = rule(
    implementation = _resolved_protoc_impl,
    executable = True,
    toolchains = [_PROTO_TOOLCHAIN],
)
