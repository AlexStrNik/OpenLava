import sys
import os
import json
import subprocess
from math import ceil
import pillow_avif
from PIL import Image


def convert_to_webm(lava_path, output_path):
    with open(f"{lava_path}/manifest.json", "r") as f:
        manifest = json.load(f)

    images = manifest["images"]
    for image in images:
        image_path = image["url"]
        Image.open(
            f"{lava_path}/{image_path}"
        ).save(f"{lava_path}/{image_path.replace('.avif', '.png')}")

    frames = []
    for frame in manifest["frames"]:
        frame = get_frame(lava_path, manifest, frame)
        frames.append(frame)

    for i, frame in enumerate(frames):
        frame.save(f"{lava_path}/frame_{i:04}.png")

    subprocess.run(
        [
            "ffmpeg",
            "-framerate",
            str(manifest["fps"]),
            "-i",
            f"{lava_path}/frame_%04d.png",
            "-c:v",
            "libvpx-vp9",
            "-pix_fmt",
            "yuv420p",
            output_path,
        ]
    )

    for i in range(len(frames)):
        os.remove(f"{lava_path}/frame_{i:04}.png")

    for image in images:
        png_path = image["url"].replace('.avif', '.png')
        os.remove(f"{lava_path}/{png_path}")


def get_frame(lava_path, manifest, frame):
    cell_size = manifest["cellSize"]
    images = []
    for image in manifest["images"]:
        png_path = image["url"].replace(".avif", ".png")
        images.append(
            Image.open(f"{lava_path}/{png_path}").copy()
        )

    if frame["type"] == "key":
        return images[frame["imageIndex"]]
    elif frame["type"] == "diff":
        frame_image = Image.new("RGBA", (images[0].width, images[0].height))

        for entry in frame["diffs"]:
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
        raise ValueError(f"Unknown frame type: {frame['type']}")


if __name__ == "__main__":
    lava_path = sys.argv[1]
    output_path = sys.argv[2]

    convert_to_webm(lava_path, output_path)
