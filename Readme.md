# OpenLava

**OpenLava** is an open-source implementation of the **Lava** media format, originally created by Airbnb. Lava is a tile-based animation format optimized for lightweight, high-performance animations.

This project provides both tools and rendering libraries for working with Lava assets on macOS, iOS, and beyond.

## 📁 Project Structure

```
.
├── Docs/                    # Format specs, API usage, and documentation
│   ├── format.md            # In-depth description of Lava's manifest and image layout
│   ├── packages.md          # Notes on the Swift package implementation
│   └── tools.md             # Python tool usage and conversion tips
│
├── Examples/
│   ├── Media/               # Extracted example Lava assets (.avif + manifest.json)
│   └── MoltenLavaExample/   # Xcode app project demonstrating real-time playback
│
├── Packages/
│   └── MoltenLava/          # Swift package implementation of Lava player
├── Tools/
│   └── convert_to_webm.py   # Python utility for rendering to .webm
│
└── Readme.md
```

## 📚 Documentation

- [Docs/format.md](Docs/format.md) – Lava manifest structure, tile math, and rendering logic
- [Docs/tools.md](Docs/tools.md) – Python script usage for exporting animations
- [Docs/packages.md](Docs/packages.md) – Swift package details for real-time rendering with Metal

Sure, here's the revised section:

## 🔍 Example Media

Browse the `Examples/Media/` folder for Lava animations extracted from the Airbnb app. These assets are provided strictly for demonstrating format compatibility and renderer behavior.

> ⚠️ **Important Notice**:
> The media files in this repository are included under fair use for educational and interoperability purposes only. **Do not reuse, redistribute, or embed these assets in your own applications or projects.** If you are affiliated with Airbnb and would like any content removed, please open an issue.

## 🚀 Roadmap

The next feature planned for development is the converter/packager that will allow conversion from frames to the Lava format. This tool will help in creating Lava animations by converting frames into the required tile-based structure and packaging them into the specific format, including the necessary manifest.

## 🧑‍💻 Contributions

Pull requests and issues are welcome! If you’ve discovered a new variant of the format or want to extend the tooling, feel free to contribute.

## 📄 License

This project is open-source under the MIT license. It is **not affiliated with Airbnb**, and no proprietary code or internals have been used or reused.

If you're from Airbnb and have questions or concerns, please reach out respectfully via the issue tracker.
