import json
from math import ceil
import pillow_avif
from PIL import Image

from .lava_manifest import LavaManifest, LavaFrame


def unpack_frames(lava_path: str, output_path: str):
    """
    Unpacks a Lava animation into individual frame images.

    Args:
        lava_path (str): Path to a Lava package directory containing manifest and images.
        output_path (str): Directory where extracted frames will be saved.
    """

    with open(f"{lava_path}/manifest.json", "r") as f:
        manifest = LavaManifest.from_dict(json.load(f))

    frames = []
    for frame in manifest.frames:
        frame = get_frame(lava_path, manifest, frame)
        frames.append(frame)

    for i, frame in enumerate(frames):
        frame.save(f"{output_path}/frame_{i:04}.avif", quality=100)


def get_frame(lava_path: str, manifest: LavaManifest, frame: LavaFrame):
    cell_size = manifest.cellSize
    images = []
    for image in manifest.images:
        png_path = image.url
        images.append(
            Image.open(f"{lava_path}/{png_path}").copy()
        )

    if frame.type == "key":
        return images[frame.imageIndex]
    elif frame.type == "diff":
        frame_image = Image.new("RGBA", (images[0].width, images[0].height))

        for entry in frame.diffs:
            source, src_tile_index, x_count, y_count, target_tile_index = entry

            src_width = ceil(images[source].width / cell_size)
            dst_width = ceil(images[0].width / cell_size)

            source_image = images[source]

            src_x = (src_tile_index % src_width) * cell_size
            src_y = (src_tile_index // src_width) * cell_size
            tile = source_image.crop(
                (src_x, src_y, src_x + x_count *
                 cell_size, src_y + y_count * cell_size)
            )

            dst_x = (target_tile_index % dst_width) * cell_size
            dst_y = (target_tile_index // dst_width) * cell_size
            frame_image.paste(tile, (dst_x, dst_y))

        return frame_image
    else:
        raise ValueError(f"Unknown frame type: {frame.type}")
