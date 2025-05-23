# OpenLava Python Tools

This repository includes a Python script to process Lava animations and convert them into `.webm` video files (with alpha support).

## 🛠 Requirements

- Python 3.11+
- [`lava-serpent`](https://pypi.org/project/lava-serpent/)
- [`ffmpeg`](https://ffmpeg.org/) installed system-wide

## 📤 Export to WebM

You can run the conversion with:

```bash
python3.11 Tools/convert_to_webm.py <lava_folder> <output.webm>
```

Example:

```bash
python3.11 Tools/convert_to_webm.py Examples/Media/m13HomepageExperiencesTabInitialAnimationLavaAssets test.webm
```

The script:

1. Parses the `manifest.json`
   ~~2. Reconstructs each animation frame from key/diff logic~~
2. Uses `lava-serpent` to unpack frames
3. Uses `ffmpeg` to encode a transparent WebM file

## 🎨 Output Format

- Transparent `.webm` (VP8/VP9 + alpha)
- Resolution based on manifest `width` / `height`
- Frame duration calculated from `fps`

## 🧪 Modifications

You may adjust the script to export as GIF (note: GIF has no alpha), PNG sequence, or feed into a Metal pipeline.
