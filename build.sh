CONFIGURATION=${1:-debug}
set -ex
swift package --allow-writing-to-package-directory generate-css --output Public/elementary.css
swift package --swift-sdk ${SWIFT_SDK_ID:-wasm32-unknown-wasi} --enable-experimental-prebuilts js -c $CONFIGURATION
cp ".build/plugins/PackageToJS/outputs/Package/flappy_swift.wasm" Public/