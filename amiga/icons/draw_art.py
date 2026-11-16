#!/usr/bin/env python3
"""Dark Well's picture for its GlowIcons (art/darkwell.png), drawn here:
upstream has none. A dark well, walled in green as the game draws it, with
a falling column of three coloured blocks and a settled row at the bottom.
64 x 64, RGBA, solid or see-through.
    python3 amiga/icons/draw_art.py amiga/icons/art
Pure Python. GPL-2.0-or-later, Copyright (c) 2026 AmiCradle Team."""
import struct, sys, zlib
from pathlib import Path

W = H = 64
INK = (16, 18, 22, 255)


def png(px, path):
    raw = b"".join(b"\0" + bytes(v for p in row for v in p) for row in px)
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    Path(path).write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0))
                           + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def draw():
    px = [[(0, 0, 0, 0)] * W for _ in range(H)]
    def rect(x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                px[y][x] = c
    def block(x, y, c):
        hi = tuple(min(255, v + 70) for v in c[:3]) + (255,)
        lo = tuple(v // 2 for v in c[:3]) + (255,)
        rect(x, y, x + 10, y + 10, lo)
        rect(x, y, x + 9, y + 9, hi)
        rect(x + 1, y + 1, x + 9, y + 9, c)
    wall = (40, 170, 60, 255)
    rect(6, 2, 58, 62, INK)             # the well
    rect(6, 2, 10, 62, wall)            # its walls and floor
    rect(54, 2, 58, 62, wall)
    rect(6, 58, 58, 62, wall)
    red, yellow, blue, cyan, magenta = (210, 40, 40, 255), (230, 200, 40, 255), (50, 80, 220, 255), (40, 190, 200, 255), (190, 50, 190, 255)
    for i, c in enumerate((magenta, yellow, cyan)):   # the falling column
        block(27, 8 + i * 10, c)
    for i, c in enumerate((red, red, red, blue)):     # three in a row, about to go
        block(12 + i * 10, 48, c)
    block(42, 38, blue)
    return px


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "amiga/icons/art")
    out.mkdir(parents=True, exist_ok=True)
    png(draw(), out / "darkwell.png")
