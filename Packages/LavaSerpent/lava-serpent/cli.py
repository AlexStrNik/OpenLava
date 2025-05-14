import sys
from .unpacker import unpack_frames
from .packer import pack_frames


def main():
    if len(sys.argv) < 3:
        print("Usage: python cli.py <command> <input> <output>")
        sys.exit(1)

    command = sys.argv[1]
    input_path = sys.argv[2]
    output_path = sys.argv[3]

    if command == "unpack":
        unpack_frames(input_path, output_path)
    elif command == "pack":
        *input_path, file_pattern = sys.argv[2].split("/")

        pack_frames("/".join(input_path), output_path, file_pattern)
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
