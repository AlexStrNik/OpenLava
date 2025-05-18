# 📦 Packages

## MoltenLava

[`MoltenLava`](../Packages/MoltenLava) is a Swift package that provides a real-time renderer for Lava animations using Metal. It includes:

- Tile-based frame decoding using `MTLBlitCommandEncoder`
- Manifest and image parsing
- Cross-platform support (macOS & iOS)
- Real-time playback via `LavaView`

### Example

See [`Examples/MoltenLavaExample`](../Examples/MoltenLavaExample) for a minimal SwiftUI app demonstrating real-time Lava animation playback.

## LavaSerpent

[`LavaSerpent`](../Packages/LavaSerpent) is a Python package for working with the Lava format from a tooling perspective. It supports:

- Converting sequences of AVIF frames into optimized Lava packages
- Unpacking Lava directories back into individual frames
- JSON parsing and serialization of manifest structure using Python dataclasses

See its [dedicated README](../Packages/LavaSerpent/README.md) for full documentation and CLI usage.

## LavaPhoenix

[`LavaPhoenix`](../Packages/LavaPhoenix) is a Flutter package that provides a GPU-accelerated renderer for Lava animations across Android, iOS, and Web — with no platform views. It includes:

- Pure Flutter rendering using `CustomPainter` and `ui.Image`
- Asynchronous asset loading and animation control via `LavaController`
- Cross-platform support: Android, iOS, and Web
- Smooth real-time playback with minimal CPU overhead
- Manifest and tile atlas parsing fully in Dart

### Example

See [`Examples/LavaPhoenixExample`](../Examples/LavaPhoenixExample) for a minimal Flutter app that demonstrates real-time playback of a Lava animation using `LavaView` and `LavaController`.

## LavaWeb

[`LavaWeb`](../Packages/LavaWeb) is a WebGL-based renderer for Lava animations, providing smooth GPU-accelerated playback directly in the browser. It features:

- Efficient WebGL rendering with custom shader pipelines
- Asynchronous asset loading and animation control via `LavaRenderer`
- Full browser compatibility with no third-party plugins
- Real-time performance optimized for low CPU usage
- Tile atlas and manifest parsing entirely in JavaScript or TypeScript

### Example

See [`Examples/LavaWebExample`](../Examples/LavaWebExample) for a minimal React app that demonstrates real-time playback of a Lava animation using `LavaRenderer`.

## 🧪 Planned Packages

Future implementations are planned in:

- Web (WebGL or WebGPU)
- Compose (Not really, i hate android sry)

## 🤝 Contributing

Contributions are welcome! Feel free to file issues, submit pull requests, or suggest new implementations in your language or framework of choice.
