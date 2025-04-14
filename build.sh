swift package --allow-writing-to-package-directory generate-css
swift package --swift-sdk ${SWIFT_SDK_ID:-wasm32-unknown-wasi} --enable-experimental-prebuilts js --use-cdn