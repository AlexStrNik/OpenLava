# OpenLava

**OpenLava** is a reverse engineering project targeting **Lava**, a custom media format developed by Airbnb. This format is designed for compact, tile-based animations—possibly used for animated UI elements or splash experiences.

> ⚠️ This project is for educational and research purposes only. No proprietary code or logic has been decompiled or reverse-engineered beyond analyzing static media assets included within an iOS IPA package.

## 📁 File Format Overview

The Lava format appears as a folder (or archive-like structure) containing media and a manifest. It is extracted from iOS `.ipa` packages, typically located under the app's assets.

Each Lava animation contains:

- `manifest.json` — metadata and animation logic
- `image_1.avif` — base image (first frame or tile atlas)
- `image_2.avif` — large diff tile atlas used for updating tiles across frames

> **Note**: File names can vary. The manifest provides references via the `images` array.

## 🧾 Manifest Structure

Example `manifest.json`:

```json
{
  "version": 1,
  "fps": 30,
  "cellSize": 32,
  "diffImageSize": 2048,
  "width": 180,
  "height": 162,
  "density": 2,
  "alpha": true,
  "images": [{ "url": "image_1.avif" }, { "url": "image_2.avif" }],
  "frames": [
    { "type": "key", "imageIndex": 0 },
    {
      "type": "diff",
      "diffs": [
        [0, 4, 2, 6, 4],
        [0, 24, 4, 2, 24],
        [0, 0, 4, 1, 0],
        ...
      ]
    }
  ]
}
```

### Key Fields:

- `fps`: Frames per second for playback
- `cellSize`: Size (in pixels) of a square tile (e.g., 32x32)
- `diffImageSize`: Width of the diff tileset image (`image_2`)
- `width` / `height`: Dimensions of the full frame (in pixels)
- `density`: Likely linked to Apple’s display scale factor (e.g., Retina = 2)
- `alpha`: Whether the frames include transparency
- `images`: A list of image files, typically `[base_image, diff_tileset]`

## 🎞 Frame Types

Two types of frames exist:

### Key Frame

```json
{ "type": "key", "imageIndex": 0 }
```

Just displays the full image directly (typically the base).

### Diff Frame

```json
{
  "type": "diff",
  "diffs": [
    [source, src_tile_index, x_tiles, y_tiles, dest_tile_index],
    ...
  ]
}
```

Diff-based frame composed by copying tiles.

### Tile Coordinates:

To calculate tile pixel coordinates:

```python
src_x = (tile_index % tiles_per_row) * cell_size
src_y = (tile_index // tiles_per_row) * cell_size
```

Where:

- `tiles_per_row = ceil(image_width / cell_size)`
- `tile_index` is either the source or destination tile index

## 🐍 Python Library

A simple Python utility is included to:

- Parse Lava manifests
- Reconstruct all frames
- Export animation as a transparent `.webm` video

### Requirements

- Python 3.11+
- `Pillow`
- `ffmpeg` (must be installed on your system)

### Usage

```bash
python3.11 convert_to_webm.py examples/m13HomepageExperiencesTabInitialAnimationLavaAssets test.webm
```

You may also modify the script to export as a GIF (without alpha).

## ⚠️ Legal Disclaimer

This repository is provided **strictly for educational purposes**. It does **not** include any reverse-engineered source code or proprietary algorithms. The only extracted materials are media files (`.avif`, `.json`) used for format analysis and placed under the `examples/` directory.

Copying, distributing, or reusing original assets from Airbnb’s app outside of fair use (such as this analysis) is **prohibited**. If you are affiliated with Airbnb and have concerns, please contact the repository owner to discuss removal or licensing.
