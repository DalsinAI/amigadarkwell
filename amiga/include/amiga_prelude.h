/* Included before Dark Well's files in the Amiga build and the host tests
 * (-include): what its 2000 Linux C took from the headers without naming
 * them, and its pauses.
 *
 * delay_output(MS): ncurses sends a terminal MS milliseconds of padding at
 * its line speed, which on the Linux console Dark Well was written on is a
 * blink; with no padding character it is MS milliseconds. Dark Well asks
 * 1000 per row of a dropped block, 4000 per column that falls and 6000
 * after lines go; a hundredth of that keeps the animation as it looked on
 * the console it was written for.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Dark Well. */
#ifndef AMIGA_PRELUDE_H
#define AMIGA_PRELUDE_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <time.h>
int delay_output(int ms);
#define delay_output(ms) delay_output((ms) / 100)
#endif
