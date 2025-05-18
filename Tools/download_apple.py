import os
import requests
from lava_serpent import pack_frames

BASE_URL = "https://www.apple.com/105/media/us/airpods-pro/2022/d2deeb8e-83eb-48ea-9721-f567cf0fffa8/anim/hero/large/"

os.makedirs("Examples/Media/AirpodsFrames", exist_ok=True)
os.makedirs("Examples/Media/AirpodsLava", exist_ok=True)

for i in range(65):
    url = f"{BASE_URL}/{i:04}.png"
    response = requests.get(url)
    if response.status_code == 200:
        with open(f"Examples/Media/AirpodsFrames/frame_{i:04}.png", "wb") as f:
            f.write(response.content)

pack_frames(
    "Examples/Media/AirpodsFrames",
    "Examples/Media/AirpodsLava",
    frame_pattern="frame_%04d.png",
    tile_size=8
)
