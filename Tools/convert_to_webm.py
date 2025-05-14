import os
import sys
import json
import subprocess
from PIL import Image
from lava_serpent import unpack_frames


def convert_to_webm(lava_path, output_path):
    with open(f"{lava_path}/manifest.json", "r") as f:
        manifest = json.load(f)

    unpack_frames(lava_path, lava_path)

    for i in range(len(manifest["frames"])):
        Image.open(
            f"{lava_path}/frame_{i:04}.avif"
        ).save(f"{lava_path}/frame_{i:04}.png")

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

    for i in range(len(manifest["frames"])):
        os.remove(f"{lava_path}/frame_{i:04}.png")


if __name__ == "__main__":
    convert_to_webm(sys.argv[1], sys.argv[2])
