from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional, Any


@dataclass
class LavaImage:
    url: str


@dataclass
class LavaFrame:
    type: str
    imageIndex: int = None
    diffs: List[List[int]] = None


@dataclass
class LavaManifest:
    version: int
    fps: int
    cellSize: int
    diffImageSize: int
    width: int
    height: int
    density: int
    alpha: bool
    images: List[LavaImage]
    frames: List[LavaFrame] = None

    @staticmethod
    def from_dict(d: Dict[str, Any]) -> 'LavaManifest':
        images = d.pop("images")
        frames = d.pop("frames")

        return LavaManifest(
            **d,
            images=[LavaImage(**i) for i in images],
            frames=[LavaFrame(**f) for f in frames],
        )
