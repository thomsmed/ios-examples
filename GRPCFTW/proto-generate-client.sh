#!/bin/sh

#  proto-generate-client.sh
#  
#  Generate Swift client stubs.
#  


set -euo pipefail

# Ensure protoc and plugins ("protoc-gen-swift" and "protoc-gen-grpc-swift") is present
if ! command -v protoc /dev/null
then
    echo 'protoc is not installed on the system'
    echo 'It can be installed using Homebrew: brew install protobuf'
    echo 'Alternatively it can be installed together with the Swfit Protobuf plugin: brew install swift-protobuf'
    exit 1
fi

if ! command -v protoc-gen-swift /dev/null
then
    echo 'protoc-gen-swift is not installed on the system'
    echo 'It can be installed using Homebrew: brew install swift-protobuf'
    exit 1
fi

if ! command -v protoc-gen-grpc-swift /dev/null
then
    echo 'protoc-gen-grpc-swift is not installed on the system'
    echo 'It can be installed using Homebrew: brew install grpc-swift'
    exit 1
fi


PROTOFILES_DIR="./GRPCFTWProtofiles"
GENERATED_DIR="./GRPCFTWClient/GRPCFTWClient/Networking/Models/Generated"


protoc $(find $PROTOFILES_DIR -iname "*.proto" | sort) \
  --proto_path=$PROTOFILES_DIR \
  --swift_opt=Visibility=Public \
  --swift_out=$GENERATED_DIR \
  --grpc-swift_opt=Visibility=Public \
  --grpc-swift_out="Client=true,TestClient=true,Server=false:$GENERATED_DIR"
