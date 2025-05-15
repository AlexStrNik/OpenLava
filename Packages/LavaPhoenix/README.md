# 🔥 LavaPhoenix

**LavaPhoenix** is a cross-platform Flutter renderer for [Lava animation format](https://github.com/AlexStrNik/OpenLava). It enables efficient tile-based animation playback with real-time performance — powered purely by Flutter rendering, without using platform views.

Designed to work seamlessly on **iOS**, **Android**, and **Web**.

## ✨ Features

- 🔁 Real-time playback of Lava animations
- 🎨 Pure Flutter rendering via `CustomPainter`
- 📦 Parses `.lava`/`.olava` animation manifests and tile atlases
- 📱 Cross-platform: iOS, Android, Web
- 🧵 Async loading and full playback control via `LavaController`
- 💡 No native plugins or platform views required

## 🚀 Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  lava_phoenix: ^0.1.0
```

## 🧰 Usage

### 1. Prepare your assets

Place your Lava animation files inside your `assets/` folder, e.g.:

```
assets/
└── animations/
    └── fire_loop/
        ├── manifest.json
        ├── image_1.avif
        ├── image_2.avif
        └── ...
```

Update your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/animations/fire_loop/
```

### 2. Load and play the animation

```dart
final controller = LavaController();

@override
void initState() {
  super.initState();
  controller.loadLavaAsset('assets/animations/fire_loop');
  controller.play();
}
```

### 3. Display the animation

```dart
LavaView(controller: controller)
```

## 📸 Example

A full working example can be found in the repository:

[**OpenLava/Example/LavaPhoenixExample**](https://github.com/AlexStrNik/OpenLava/tree/main/Example/LavaPhoenixExample)

You can run it via:

```sh
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

## 📂 File Format

This package plays back Lava animations packaged as a folder containing:

- `manifest.json`: animation metadata and frame diffs
- atlas frames: referenced in the manifest by filename

Compatible with `.lava` or `.olava` zip-style folders unpacked manually.

## 🤝 Contributing

Contributions are welcome!

Feel free to open an issue or submit a PR if you’d like to improve rendering performance, support new features, or extend platform support.

## 📄 License

MIT License © 2025 [AlexStrNik](https://github.com/AlexStrNik)
