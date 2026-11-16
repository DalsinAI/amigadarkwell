# Dark Well for GFOS

The AmiCradle Team's port of Boris Kozlov's Dark Well, a columns game
(three or more blocks of one colour in a row go), to GFOS: AmigaOS 3.2
with GFOpenUp, 68040/68060. It runs in its own 80 x 25 console window, in
colour: no SDL, no ACGame and no GFOpenGPU. It ships as a release archive
with an Installer and as the GFOpenUp part Parts/DarkWell.

Upstream's 1.0.0 release is fetched at build time and checked
(package/darkwell.lock) and patched (amiga/patches); this repository holds
only the Amiga port. See [AMIGA_PORT.md](AMIGA_PORT.md).

GPL-2.0-or-later, like Dark Well. Copyright (c) 2026 AmiCradle Team.
