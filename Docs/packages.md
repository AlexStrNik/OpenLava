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

## 🧪 Planned Packages

Future implementations are planned in:

- Web (WebGL or WebGPU)
- Flutter
- Compose (Not really, i hate android sry)

## 🤝 Contributing

Contributions are welcome! Feel free to file issues, submit pull requests, or suggest new implementations in your language or framework of choice.
