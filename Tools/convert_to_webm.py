import os
import subprocess
import pillow_avif
from lavaserpent import unpack_frames


def convert_to_webm(lava_path, output_path):

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

    # Clean up temporary files
    for i in range(len(frames)):
        os.remove(f"{lava_path}/frame_{i:04}.png")
