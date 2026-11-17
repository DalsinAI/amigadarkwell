/* Dark Well's console window, set before the game's initscr(): 80 x 25
 * (its pictures are 25 lines, as on the PC) and its title. GFOpenCurses
 * opens the window at LINES lines, titled acurses_title.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Dark Well. */
#include "curses.h"

#ifndef DARKWELL_TITLE
#define DARKWELL_TITLE "Dark Well"
#endif

__attribute__((constructor)) static void darkwell_screen(void)
{
	LINES = 25;
	acurses_title = DARKWELL_TITLE;
}
