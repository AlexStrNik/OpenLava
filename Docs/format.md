# Lava Media Format Specification

Lava is a tile-based animation format extracted created by Airbnb. Each animation appears as a folder containing:

- `manifest.json` – Describes frames and layout
- `image_1.avif` – Base frame image or initial tile atlas
- `image_2.avif` – Diff tileset image used for patching animation frames

File names may vary; they are referenced inside the manifest.

## 🧾 Manifest Structure

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
  "frames": [...]
}
```

### Field Breakdown

- `fps`: Target playback rate
- `cellSize`: Width/height of each tile (e.g., 32×32 px)
- `diffImageSize`: Width of the diff image in pixels
- `width` / `height`: Final frame size
- `density`: Apple Retina scaling factor
- `alpha`: Enables transparency support
- `images`: Referenced image files

## 🎞 Frame Types

### Key Frame

```json
{ "type": "key", "imageIndex": 0 }
```

Displays a full image from the `images` list.

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

A **diff frame** is built by copying specific tiles from a source image (usually the diff tileset) onto a new canvas. This canvas is initialized using the base image (typically `image_1.avif`), and patches are applied on top based on the `diffs` array.

Unlike traditional video diffs, this frame does **not** depend on the previous frame. Instead, it is constructed independently using:

- A base key image
- A set of tile patches

Each `diff` entry contains:

```
[source_image_index, source_tile_index, width_in_tiles, height_in_tiles, destination_tile_index]
```

This tells the renderer where to read and paste tiles from the diff tileset.

## 🧮 Tile Coordinate Calculation

To determine pixel coordinates for tiles:

```python
tile_x = (tile_index % tiles_per_row) * cell_size
tile_y = (tile_index // tiles_per_row) * cell_size
```

Where:

- `tiles_per_row = ceil(image_width / cell_size)`
- `cell_size` is the fixed tile size (e.g., 32 pixels)

This logic is used for both the source and destination positions when copying tile blocks between atlases.

## 🖼️ Frame Rendering Logic

Each frame is rendered by iterating over the `diffs` array in the manifest. For each diff entry:

```json
[source_index, source_tile_index, width_in_tiles, height_in_tiles, destination_tile_index]
```

- A rectangular region of size `(width_in_tiles × height_in_tiles)` tiles is copied.
- The **source position** is computed using `source_tile_index` within the image at `images[source_index]`.
- The **destination position** is computed from `destination_tile_index` into the output frame.
- Both positions are calculated using the tile coordinate logic above, and converted to pixel regions by multiplying by `cell_size`.

This mechanism allows compact updates by reusing small tile regions from large atlases.
