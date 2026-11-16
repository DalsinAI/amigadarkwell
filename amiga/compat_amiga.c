/* What Dark Well asks of Unix that libnix answers otherwise (Amiga build
 * only; the host's C library has them):
 *  - gettimeofday(), for the falling block's clock: dos.library DateStamp,
 *    to the 50th of a second;
 *  - random(), which on the Linux C library is rand() (srand() seeds both,
 *    and Dark Well seeds only srand()).
 * The Makefile renames upstream's calls to these.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Dark Well. */
#include <stdlib.h>
#include <sys/time.h>

#include <dos/dos.h>
#include <proto/dos.h>

int amiga_gettimeofday(struct timeval *tv, void *tz)
{
	struct DateStamp ds;

	(void)tz;
	DateStamp(&ds);
	tv->tv_sec = (long)ds.ds_Days * 86400L + (long)ds.ds_Minute * 60L + ds.ds_Tick / TICKS_PER_SECOND;
	tv->tv_usec = (long)(ds.ds_Tick % TICKS_PER_SECOND) * (1000000L / TICKS_PER_SECOND);
	return 0;
}

long amiga_random(void) { return (long)rand(); }
