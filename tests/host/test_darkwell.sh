#!/bin/sh
# Host tests for the Amiga port of Dark Well: upstream's game (amiga/patches
# applied, __amigaos__ set, so the Amiga's paths are the ones built) with
# GFOpenCurses over a plain terminal (its src/console_host.c), played
# with scripted keys; GFOpenCurses' tests/host/vt.py reads back the 80 x 25 screen as the
# Amiga's console would show it:
#  - keys: Return is CR after nonl(), the cursor keys come as KEY_*;
#  - CP437: the PC's lines and corners as ASCII, its letters as Latin-1,
#    its blocks as a reversed space, in curses and in acurses_raw();
#  - the title screen (upstream's ANSI art, its blocks reversed), and the
#    window's close there ends the game;
#  - h shows the help page in its box;
#  - Return starts a game: the well in its walls, the top ten, the stats,
#    the quick help, the falling blocks and the next ones in colour;
#    + raises the speed; Space drops the block to the floor;
#  - q and y leave: the goodbye screen (its art).
# Needs a C compiler and python3; skipped without a compiler.
#   UP=/path/to/darkwell (patched) sh tests/host/test_darkwell.sh
# Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Dark Well.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)
UP=${UP:?UP=upstream source}
CC=${HOSTCC:-cc}
command -v "$CC" >/dev/null 2>&1 || { echo "host tests: skipped (no C compiler)"; exit 0; }
T=$(mktemp -d "${TMPDIR:-/tmp}/darkwell-host.XXXXXX")
[ -n "${TEST_KEEP:-}" ] || trap 'rm -rf "$T"' EXIT INT TERM
cd "$ROOT"
export VT_ROWS=25

# the drawer: the top ten where PROGDIR: would be
mkdir -p "$T/drawer"
: > "$T/drawer/darkwell.score"

GC=${GFOPENCURSES:?GFOPENCURSES=gfopencurses checkout}
VT=$GC/tests/host/vt.py
MINE="-std=gnu99 -Wall -Werror -D_XOPEN_SOURCE=600 -D_DEFAULT_SOURCE -I$GC/include -Iamiga/include -Iamiga"
for f in curses keys; do $CC $MINE -c -o "$T/$f.o" "$GC/src/$f.c"; done
$CC $MINE -c -o "$T/con.o" "$GC/src/console_host.c"
$CC $MINE -c -o "$T/screen.o" amiga/screen.c
for f in main draw unix score; do
    $CC -std=gnu89 -fpermissive -fcommon -w -D__amigaos__ -DSCORE_FILE="\"$T/drawer/darkwell.score\"" \
        -include amiga/include/amiga_prelude.h -I$GC/include -Iamiga/include -Iamiga -c -o "$T/u_$f.o" "$UP/$f.c"
done
$CC -o "$T/darkwell" "$T"/u_*.o "$T/curses.o" "$T/keys.o" "$T/con.o" "$T/screen.o"

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }

cat > "$T/units.c" <<'C'
#include <stdio.h>
#include <string.h>
#include "curses.h"
static const unsigned char *p; static int n;
static int next(void) { return n-- > 0 ? *p++ : -1; }
int main(void)
{
	static const unsigned char in[] = { '\r', 0x9b, 'A', 0x1b, '[', 'D' };
	static const struct { int c; chtype want; } m[] = {
		{ 0xc4, '-' }, { 0xb3, '|' }, { 0xda, '+' }, { 0xc5, '+' }, { 0xba, '|' },
		{ 0xcd, '-' }, { 0xdb, ' ' | A_REVERSE }, { 0xdf, ' ' | A_REVERSE },
		{ 0xb1, '%' }, { 0x82, 0xe9 }, { 0x81, 0xfc }, { 'A', 'A' },
	};
	int bad = 0, c, i;
	p = in; n = sizeof in;
	amiga_keys_keypad = 1;
	amiga_keys_crnl = 0;
	if ((c = amiga_key_decode(next)) != '\r') { printf("nonl: %d\n", c); bad = 1; }
	if ((c = amiga_key_decode(next)) != KEY_UP) { printf("up: %d\n", c); bad = 1; }
	if ((c = amiga_key_decode(next)) != KEY_LEFT) { printf("left: %d\n", c); bad = 1; }
	for (i = 0; i < (int)(sizeof m / sizeof m[0]); i++)
		if (acurses_cp437_char(m[i].c) != m[i].want) {
			printf("cp437 %02x: %x\n", m[i].c, (unsigned)acurses_cp437_char(m[i].c)); bad = 1;
		}
	return bad;
}
C
$CC $MINE -o "$T/units" "$T/units.c" "$T/curses.o" "$T/keys.o" "$T/con.o" "$T/screen.o"
if "$T/units"; then ok "keys, and CP437 as Latin-1, ASCII lines and reversed blocks"; else bad "units"; fi

# acurses_raw: the text as it is, CP437 mapped, the blocks reversed
cat > "$T/raw.c" <<'C'
#include "curses.h"
int main(void) { acurses_raw("\033[1;1Ha\333b\304c\202"); return 0; }
C
$CC $MINE -o "$T/raw" "$T/raw.c" "$T/curses.o" "$T/keys.o" "$T/con.o" "$T/screen.o"
"$T/raw" > "$T/raw.out"
if [ "$(od -An -c "$T/raw.out" | tr -s ' ' | tr -d '\n')" = " 033 [ 1 ; 1 H a 033 [ 7 m 033 [ 2 7 m b - c 351" ]; then
    ok "acurses_raw: CP437 mapped, a block as CSI 7 m, space, CSI 27 m"
else bad "acurses_raw: $(od -An -c "$T/raw.out")"; fi

play() {	# keys (printf format), output
    (cd "$T" && printf "$1" | timeout 30 ./darkwell > "$2" 2>&1)
}
want() {	# name, output, vt.py arguments...
    name=$1; out=$2; shift 2
    if python3 "$VT" "$out" "$@" > "$T/vt.txt"; then ok "$name"; else bad "$name"; cat "$T/vt.txt"; fi
}

if play '' "$T/title.out"; then ok "the window's close at the title ends the game"; else bad "the end of the input did not end it"; fi
want "the title screen: upstream's art, its blocks reversed" "$T/title.out" \
    --want "for game help" --want "v. 1.0.0" --reversed 60
play 'h' "$T/help.out"
want "h: the help page in its box" "$T/help.out" \
    --want "Game Help" --want "Keys for moving blocks" --want "- move block left" --want "+------" --want "Press any key."
play '\r++' "$T/game.out"
want "Return: the well, the top ten, the stats, the blocks; + raises the speed" "$T/game.out" \
    --want "Top Ten" --want "Stats" --want "Score       : 0" --want "Speed       : 3" --want "Next colors" \
    --want "Quick help" --want "left,j  - move left" --want "+--------------------------+" --reversed 12
python3 "$VT" "$T/game.out" --blocks | sed -n 2,23p | cut -c28-55 > "$T/well.txt"
if [ "$(grep -c '^|.*|$' "$T/well.txt")" -ge 20 ]; then ok "the well's walls"; else bad "the well's walls"; cat "$T/well.txt"; fi
play '\r ' "$T/drop.out"
python3 "$VT" "$T/drop.out" --blocks | sed -n 21,23p | cut -c28-55 > "$T/floor.txt"
if grep -q '##' "$T/floor.txt"; then ok "Space drops the block to the floor"; else bad "drop"; python3 "$VT" "$T/drop.out" --blocks; fi
if play '\rqy' "$T/bye.out"; then ok "q and y leave the game"; else bad "q y"; fi
want "the goodbye screen" "$T/bye.out" --reversed 40

if [ "$fails" = 0 ]; then echo "host tests: all passed"; else echo "host tests: $fails failed"; exit 1; fi
