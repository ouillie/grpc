#!/usr/bin/env bash
# A stand-in for the real gRPC protoc plugins, used by this test module.
#
# protoc feeds a CodeGeneratorRequest on stdin (which we ignore) and expects a
# serialized CodeGeneratorResponse on stdout. We build that response with
# `protoc --encode` over a schema whose field numbers match CodeGeneratorResponse,
# emitting one trivial file per gRPC codegen output. protoc writes each file
# relative to the invoking --<lang>_out directory, so this single plugin can back
# the C++, Objective-C and Python toolchains at once: every codegen action keeps
# only the outputs it declared and discards the rest.
set -euo pipefail

# protoc is a runfile of this plugin (see the sh_binary's `data`). Finding it here
# only works if the plugin's runfiles are staged into the codegen action.
protoc="$(find -L "${RUNFILES_DIR:-$0.runfiles}" -type f -name protoc -print -quit)"

cat >/dev/null  # discard the CodeGeneratorRequest

schema="$(mktemp)"
cat >"$schema" <<'PROTO'
syntax = "proto3";
message CodeGeneratorResponse {
  message File {
    string name = 1;
    string content = 15;
  }
  repeated File file = 15;
}
PROTO

"$protoc" --encode=CodeGeneratorResponse -I"$(dirname "$schema")" "$(basename "$schema")" <<'RESPONSE'
file { name: "helloworld.grpc.pb.h" }
file { name: "helloworld.grpc.pb.cc" }
file { name: "Helloworld.pbrpc.h" }
file { name: "Helloworld.pbrpc.m" }
file { name: "helloworld_pb2_grpc.py" }
RESPONSE
