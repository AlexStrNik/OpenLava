import re
import math
import json
import rpack
import os
import hashlib
import pillow_avif
from PIL import Image
from collections import defaultdict
from dataclasses import dataclass, asdict
from typing import List, Dict, Tuple, Optional

from .lava_manifest import LavaManifest, LavaFrame, LavaImage


@dataclass
class TileMap:
    frame_tile_ids: List[List[List[int]]]
    tile_id_to_info: Dict[int, Tuple[int, Tuple[int, int]]]
    tile_size: int


@dataclass
class Patch:
    id: int
    tiles: List[List[int]]


@dataclass
class Diff:
    is_patch: bool
    dest_tile_index: int
    source_tile_index: Optional[Tuple[int, int]]
    x_tiles: int
    y_tiles: int
    patch_id: Optional[int]
    patch_offset_x: int
    patch_offset_y: int


@dataclass
class DiffPatches:
    patches: List[Patch]
    diffs_per_frame: List[List[Diff]]


@dataclass
class PackedPatches:
    id_map: Dict[int, Tuple[int, int]]
    bin_w: int
    bin_h: int


def hash_tile(tile: Image.Image) -> str:
    return hashlib.sha1(tile.tobytes()).hexdigest()


def tiles_equal(t1: Image.Image, t2: Image.Image) -> bool:
    return t1.tobytes() == t2.tobytes()


def load_frames(path: str, pattern: str = None):
    frames = []

    if pattern:
        match = re.search(r"%0(\d+)d", pattern)
        if not match:
            raise ValueError("Pattern must include something like %0Nd")

        digit_count = int(match.group(1))
        regex_pattern = re.escape(pattern).replace(
            f"%0{digit_count}d", f"(\\d{{{digit_count}}})")
        frame_re = re.compile(f"^{regex_pattern}$")

        matched_files = []
        for file in os.listdir(path):
            m = frame_re.match(file)
            if m:
                index = int(m.group(1))
                matched_files.append((index, file))

        for _, file in sorted(matched_files):
            frames.append(Image.open(os.path.join(path, file)))
    else:
        for file in sorted(os.listdir(path)):
            if file.lower().endswith(".avif"):
                frames.append(Image.open(os.path.join(path, file)))

    return frames


def build_tile_map(
    frames: list[Image.Image],
    tile_size: int,
) -> TileMap:
    tile_id_counter = 0
    hash_to_ids = defaultdict(list)
    tile_id_to_info = {}
    frame_tile_ids = []

    for frame_idx, img in enumerate(frames):
        width, height = img.size
        tiles_x = math.ceil(width / tile_size)
        tiles_y = math.ceil(height / tile_size)

        frame_map = []

        for ty in range(tiles_y):
            row = []
            for tx in range(tiles_x):
                left = tx * tile_size
                upper = ty * tile_size
                tile = img.crop(
                    (left, upper, left + tile_size, upper + tile_size)
                )

                h = hash_tile(tile)
                matched_id = None

                for candidate_id in hash_to_ids[h]:
                    ref_frame_idx, (ref_x,
                                    ref_y) = tile_id_to_info[candidate_id]
                    ref_tile = frames[ref_frame_idx].crop((
                        ref_x * tile_size, ref_y * tile_size,
                        (ref_x + 1) * tile_size, (ref_y + 1) * tile_size
                    ))
                    if tiles_equal(tile, ref_tile):
                        matched_id = candidate_id
                        break

                if matched_id is not None:
                    tile_id = matched_id
                else:
                    tile_id = tile_id_counter
                    tile_id_counter += 1
                    hash_to_ids[h].append(tile_id)
                    tile_id_to_info[tile_id] = (frame_idx, (tx, ty))

                row.append(tile_id)
            frame_map.append(row)

        frame_tile_ids.append(frame_map)

    return TileMap(
        frame_tile_ids=frame_tile_ids,
        tile_id_to_info=tile_id_to_info,
        tile_size=tile_size
    )


def patch_contains(patch_tiles, sub_tiles):
    patch_h = len(patch_tiles)
    patch_w = len(patch_tiles[0])
    sub_h = len(sub_tiles)
    sub_w = len(sub_tiles[0])

    for oy in range(patch_h - sub_h + 1):
        for ox in range(patch_w - sub_w + 1):
            match = True
            for y in range(sub_h):
                for x in range(sub_w):
                    if patch_tiles[oy + y][ox + x] != sub_tiles[y][x]:
                        match = False
                        break
                if not match:
                    break
            if match:
                return ox, oy
    return None


def build_diff_patches(tile_map: TileMap) -> DiffPatches:
    base = tile_map.frame_tile_ids[0]
    all_frames = tile_map.frame_tile_ids

    height = len(base)
    width = len(base[0])
    num_frames = len(all_frames)

    patches = []
    diffs_per_frame = []

    for frame_idx in range(1, num_frames):
        frame = all_frames[frame_idx]
        visited = [[False] * width for _ in range(height)]
        diffs = []

        y = 0
        while y < height:
            x = 0
            while x < width:
                if visited[y][x]:
                    x += 1
                    continue

                equal = (frame[y][x] == base[y][x])

                max_w = 1
                while x + max_w < width and not visited[y][x + max_w]:
                    if (frame[y][x + max_w] == base[y][x + max_w]) != equal:
                        break
                    max_w += 1

                max_h = 1
                while y + max_h < height and all(
                    not visited[y + max_h][x + dx] and
                    (frame[y + max_h][x + dx] ==
                     base[y + max_h][x + dx]) == equal
                    for dx in range(max_w)
                ):
                    max_h += 1

                for dy in range(max_h):
                    for dx in range(max_w):
                        visited[y + dy][x + dx] = True

                dest_tile_index = y * width + x

                if equal:
                    diffs.append(Diff(
                        is_patch=False,
                        dest_tile_index=dest_tile_index,
                        source_tile_index=dest_tile_index,
                        x_tiles=max_w,
                        y_tiles=max_h,
                        patch_id=None,
                        patch_offset_x=0,
                        patch_offset_y=0
                    ))
                else:
                    sub_tiles = [
                        [frame[y + dy][x + dx] for dx in range(max_w)]
                        for dy in range(max_h)
                    ]

                    matched_patch_id = None
                    offset = None
                    for patch in patches:
                        offset = patch_contains(patch.tiles, sub_tiles)
                        if offset:
                            matched_patch_id = patch.id
                            break

                    if matched_patch_id is None:
                        matched_patch_id = len(patches)
                        patches.append(Patch(
                            id=matched_patch_id,
                            tiles=sub_tiles
                        ))
                        offset = (0, 0)

                    diffs.append(Diff(
                        is_patch=True,
                        dest_tile_index=dest_tile_index,
                        source_tile_index=None,
                        x_tiles=max_w,
                        y_tiles=max_h,
                        patch_id=matched_patch_id,
                        patch_offset_x=offset[0],
                        patch_offset_y=offset[1]
                    ))

                x += max_w
            y += 1

        diffs_per_frame.append(diffs)

    return DiffPatches(
        patches=patches,
        diffs_per_frame=diffs_per_frame
    )


def pack_patches(patches: List[Patch]) -> PackedPatches:
    rectangles = []
    id_map = {}

    for patch in patches:
        patch_h = len(patch.tiles)
        patch_w = len(patch.tiles[0])
        rectangles.append((patch_w, patch_h))

    positions = rpack.pack(rectangles)
    bin_w, bin_h = rpack.bbox_size(rectangles, positions)

    for idx, patch in enumerate(patches):
        patch_id = patch.id
        id_map[patch_id] = positions[idx]

    return PackedPatches(
        id_map=id_map,
        bin_w=bin_w,
        bin_h=bin_h
    )


def build_diff_image(packed_patches: PackedPatches, patches: List[Patch], tile_map: TileMap, frames: List[Image.Image]) -> Image.Image:
    tile_id_to_info = tile_map.tile_id_to_info
    tile_size = tile_map.tile_size

    diff_image = Image.new(
        "RGBA", (packed_patches.bin_w * tile_size,
                 packed_patches.bin_h * tile_size), (0, 0, 0, 0)
    )

    for patch in patches:
        px, py = packed_patches.id_map[patch.id]
        tile_grid = patch.tiles

        for row_idx, row in enumerate(tile_grid):
            for col_idx, tile_id in enumerate(row):
                frame_index, (tile_x, tile_y) = tile_id_to_info[tile_id]
                tile_img = frames[frame_index].crop((
                    tile_x * tile_size,
                    tile_y * tile_size,
                    (tile_x + 1) * tile_size,
                    (tile_y + 1) * tile_size,
                ))

                dst_x = (px + col_idx) * tile_size
                dst_y = (py + row_idx) * tile_size

                diff_image.paste(tile_img, (dst_x, dst_y))

    return diff_image


def build_manifest(frames: List[Image.Image], tile_size: int, diff_patches: DiffPatches, packed_patches: PackedPatches) -> LavaManifest:
    frame_size = frames[0].size

    manifest_frames = [
        LavaFrame(
            type="key",
            imageIndex=0
        )
    ]

    for frame_idx in range(1, len(frames)):
        manifest_diffs = []
        frame_diffs = diff_patches.diffs_per_frame[frame_idx - 1]
        for diff in frame_diffs:
            if diff.is_patch:
                px, py = packed_patches.id_map[diff.patch_id]
                src_x, src_y = px + diff.patch_offset_x, py + diff.patch_offset_y
                src_width = packed_patches.bin_w
                source_tile_index = src_y * src_width + src_x

                lava_diff = [
                    1,
                    source_tile_index,
                    diff.x_tiles,
                    diff.y_tiles,
                    diff.dest_tile_index
                ]
                manifest_diffs.append(lava_diff)
            else:
                lava_diff = [
                    0,
                    diff.source_tile_index,
                    diff.x_tiles,
                    diff.y_tiles,
                    diff.dest_tile_index
                ]
                manifest_diffs.append(lava_diff)

        manifest_frames.append(LavaFrame(
            type="diff",
            diffs=manifest_diffs
        ))

    return LavaManifest(
        version=1,
        fps=30,
        cellSize=tile_size,
        diffImageSize=packed_patches.bin_w * tile_size,
        width=frame_size[0],
        height=frame_size[1],
        density=2,
        alpha=True,
        images=[
            LavaImage(url="image_1.avif"),
            LavaImage(url="image_2.avif")
        ],
        frames=manifest_frames
    )


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

    frames = load_frames(frames_path, frame_pattern)
    tile_map = build_tile_map(frames, tile_size)
    diff_patches = build_diff_patches(tile_map)
    packed_patches = pack_patches(diff_patches.patches)
    diff_image = build_diff_image(
        packed_patches,
        diff_patches.patches,
        tile_map,
        frames,
    )

    os.makedirs(output_path, exist_ok=True)

    frames[0].save(f"{output_path}/image_1.avif", quality=100)

    diff_image.save(f"{output_path}/image_2.avif", quality=100)
    manifest = build_manifest(frames, tile_size, diff_patches, packed_patches)

    with open(f"{output_path}/manifest.json", "w") as f:
        json.dump(asdict(manifest), f, indent=4)
