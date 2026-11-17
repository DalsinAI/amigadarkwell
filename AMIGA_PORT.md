Dark Well 1.0.0 for GFOS
========================

Boris Kozlov's Dark Well (2000), a columns game: a column of three
coloured blocks falls down the well; line up three or more of one colour
down, across or on a diagonal and they go, and the blocks above fall.
Diagonals score most, and hiding the next colours scores more.

Return on the title screen starts a game, h shows the help, q leaves.
In the game the cursor keys (or j, l, i, k) move the column and turn its
colours; Space drops it, Return lets it slide; p pauses, + speeds up, n
hides the next colours, s turns the sound off and on, g starts again, q
asks to leave. The top ten is kept in darkwell.score beside the program,
and an update leaves it.

What it needs
-------------
GFOS (AmigaOS 3.2 with GFOpenUp) on a 68040 or 68060; no FPU. The game
runs in an 80 x 25 console window on any screen with eight colours or
more: no SDL, no ACGame, no GFOpenGPU.

How it was ported
-----------------
The game is built from upstream's release as it is. Upstream draws with
the PC's console character set (CP437): its well walls are box-drawing
lines and its blocks are solid blocks, and its title and goodbye screens
are PC ANSI art. GFOpenCurses (DalsinAI/gfopencurses, the curses shared by
our console ports) maps CP437 when a program asks: lines and
corners as ASCII, letters as their Latin-1 likeness, shades as : % #, and
the blocks as a reversed space, which shows as a block in the colour pair's
pen; acurses_raw() sends the ANSI art through the same mapping. The screen
is 25 lines here (ACURSES_LINES). amiga/console_amiga.c opens the window
and reads the keys (amiga/keys.c), amiga/compat_amiga.c gives the falling
block its clock (dos.library DateStamp) and random().

The one patch, amiga/patches/0001: the title and goodbye art through
acurses_raw() and the keys there through curses (no tty after endwin),
a look at the goodbye screen before the window closes, the console's bell
for the PC speaker's tones, no Linux console charset switches, the top
ten in PROGDIR:, and a fix to the name entry (a nine-letter name was left
unterminated). ncurses' delay_output() padding is a hundredth of its
milliseconds here (amiga/include/amiga_prelude.h), as quick as it was on
the Linux console.

Tests: tests/host/test_darkwell.sh builds the game on the build machine
over a plain terminal with the Amiga paths, plays it with scripted keys
and reads back the 25-line screen (the title art and its blocks, the help
page, the well and its walls, the stats, + and the speed, Space dropping
a block to the floor, q and y and the goodbye screen, the window's close),
and checks the key decoder, the CP437 mapping and acurses_raw().

Credits
-------
Dark Well (c) 2000 Boris Kozlov, GPL-2.0-or-later (COPYING.txt;
ReadMe-DarkWell is upstream's README).
Amiga port: Designed, tested and delivered by The AmiCradle Team.
Copyright (c) 2026 AmiCradle Team, GPL-2.0-or-later like Dark Well.
