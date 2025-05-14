# LavaSerpent 🐍🔥

**LavaSerpent** is a Python library for working with the Lava animation format originally developed by Airbnb. It allows you to easily **pack** a sequence of image frames into the Lava format, and **unpack** existing Lava animations into individual frames for inspection or conversion.

This package also includes data classes and helpers for parsing and generating `manifest.json` files used by Lava.

## ✨ Features

- Convert frame sequences into Lava-compatible animations
- Export Lava animations back into frame sequences
- Parse and generate Lava `manifest.json` files using `dataclasses`
- Compatible with `.avif` frame sequences (via PIL + AVIF plugin)

## 📦 Installation

```bash
pip install lava-serpent
```

Requires:

- Python 3.10+
- [Pillow](https://python-pillow.org/) with AVIF support (e.g., via `pillow-avif-plugin`)

## 🚀 Usage

### Packing Frames

```python
from lavaserpent import pack_frames

pack_frames(
    frames_path="frames/",
    output_path="output_lava/",
    frame_pattern="frame_%04d.avif",
    tile_size=32,
)
```

### Unpacking Frames

```python
from lavaserpent import unpack_frames

unpack_frames(
    lava_path="output_lava/",
    output_path="extracted_frames/"
)
```

## 🧾 API Reference

### `pack_frames`

```python
def pack_frames(
    frames_path: str,
    output_path: str,
    frame_pattern: str = None,
    tile_size: int = 32,
):
    """
    Packs a directory of frames into the Lava format.

    Args:
        frames_path (str): Path to a directory containing input frames (e.g., AVIF images).
        output_path (str): Path to save the resulting Lava package (includes manifest + images).
        frame_pattern (str, optional): FFmpeg-style frame naming pattern (e.g., "frame_%04d.avif").
                                       If omitted, all .avif files in the directory will be used.
        tile_size (int): Size of each square tile (e.g., 32 for 32x32 tiles).
    """
```

### `unpack_frames`

```python
def unpack_frames(
    lava_path: str,
    output_path: str,
):
    """
    Unpacks a Lava animation into individual frame images.

    Args:
        lava_path (str): Path to a Lava package directory containing manifest and images.
        output_path (str): Directory where extracted frames will be saved.
    """
```

Here's the updated section of the `README.md` including a note and usage example for the simple CLI:

---

## 🧰 Command-Line Interface (CLI)

LavaSerpent includes a simple CLI for packing and unpacking animations directly from the terminal.

### 🔧 Usage

```bash
# Pack frames into Lava format
poetry run lava-serpent pack Frames/frame_%04d.avif OutputLava

# Unpack a Lava package into individual frames
poetry run lava-serpent unpack LavaDir Frames
```

You can also use this via `python -m lavaserpent` if you prefer.

## 👋 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests with bugfixes, enhancements, or format insights.

## 📜 License

MIT License
