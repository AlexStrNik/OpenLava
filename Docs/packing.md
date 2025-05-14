## 🧪 Lava Packing Algorithm

**This implementation is an original algorithm designed to generate Lava-compatible manifests and diff images. It was developed independently and is not based on any decompiled or reverse-engineered code from Airbnb's internal tooling.**

The algorithm converts a sequence of AVIF frames into an efficient, tile-based Lava animation format. It proceeds in four key stages:

### 🧩 Stage 1: Tile Deduplication

Each input frame is divided into fixed-size square tiles (e.g., 32×32 pixels). For every tile:

- A fast hash (similar to Karp-Rabin) is computed.
- If the hash has been seen before, the tile is compared pixel-by-pixel against previous matches.
- If it's identical, the tile is assigned the same **Tile ID**.
- Otherwise, a new ID is assigned.

Internally, two lookup maps are maintained:

- `hash → [candidate_tile_ids]`
- `tile_id → (frame_index, tile_origin)`

This enables efficient detection and reuse of identical visual data.

### 🧱 Stage 2: Diff Map Construction

Starting from the base frame (typically the first one), each subsequent frame is compared tile-by-tile:

- The algorithm greedily scans for the largest possible **uniform rectangles** (patches) that are either:

  - Completely identical to the base image
  - Or completely different (and thus need patching)

If a differing area is found:

- A new **Patch** object is created, storing the rectangular block of tile IDs.
- Before adding the patch, it checks whether an identical region is already covered by a previously defined patch.
- If so, the patch is skipped to reduce redundancy.

The result is a per-frame **diff map** — a series of rectangular updates with associated tile data and references to source patches.

### 📦 Stage 3: Patch Packing

All unique patches collected across frames are passed into a **rectangle packing** algorithm to pack them into a tight atlas layout. This reduces the final diff image size.

Output:

- Global tile atlas layout
- `patch_id → (x, y)` position within the atlas image

### 🧮 Stage 4: Final Manifest and Diff Image

With the global tile atlas defined:

- Each frame’s diff entries are updated to use real atlas coordinates (instead of placeholder IDs).
- A manifest is generated describing all patches and per-frame diffs.
- A single `.avif` tile atlas image is rendered containing all patch tiles.

The result is a compact, manifest-driven Lava animation ready for playback in compatible players like [MoltenLava](../Packages/MoltenLava).

This custom pipeline is implemented in Python and designed for both accuracy and performance. Contributions are welcome — especially for performance optimizations or additional format exporters!
