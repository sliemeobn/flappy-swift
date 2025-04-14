APP_NAME=flappy_swift
TRIPPLE=wasm32-unknown-none-wasm

BUILD_DIR=$(swift build -c release --triple $TRIPPLE --show-bin-path)

set -ex

swift package --allow-writing-to-package-directory generate-css --output Public/elementary.css

swift build -c release --product $APP_NAME \
  --triple $TRIPPLE \
  --enable-experimental-prebuilts \
  --toolset BuildSupport/embedded-toolset.json

BuildSupport/link-embedded-wasm.sh "$BUILD_DIR" $APP_NAME

cp "$BUILD_DIR/$APP_NAME.wasm" Public/