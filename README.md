# Flappy Swift

**A DOM-rendered WASM game in ~100KB, written in Swift.**

A technical demonstration of [ElementaryDOM](https://github.com/sliemeobn/elementary-dom) and [ElementaryCSS](https://github.com/sliemeobn/elementary-css) rendering performance, implemented as a "Flappy Bird" clone. This project serves as a playground for exploring the capabilities and performance characteristics of DOM-based rendering in Swift.

Intentionally, *Flappy Swift* does not use Canvas or WebGL, but renders directly to the DOM instead. Every animation frame is going through the full reactivity-based reconciling/V-DOM logic without any special tricks or shortcuts.

[**>> Play it here <<**](https://sliemeobn.github.io/flappy-swift/)

## Build and Run

Requires Swift 6.1 or later

```sh
# Embedded Swift
./build-embedded.sh
npx serve Public
```

Or, alternatively, using "full swift"
```sh
# Requires SwiftWasm SDK (https://book.swiftwasm.org/getting-started/setup.html)
./build.sh
npx serve Public
```
