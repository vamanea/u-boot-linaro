/*
 * (C) Copyright 2000-2003
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * Secure boot support
 */
#include <common.h>
#include <command.h>
#include <net.h>

void _monitor_call(ulong	addr);
/* Allow ports to override the default behavior */
__attribute__((weak))
unsigned long do_go_exec (ulong (*entry)(int, char * const []), int argc, char * const argv[])
{
	return entry (argc, argv);
}

int do_boots (cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	ulong	addr, rc;
	int     rcode = 0;

	if (argc < 2)
		return CMD_RET_USAGE;

	addr = simple_strtoul(argv[1], NULL, 16);

	printf ("## Starting application at 0x%08lX ...\n", addr);

	/*
	 * pass address parameter as argv[0] (aka command name),
	 * and all remaining args
	 */
	//rc = do_go_exec ((void *)addr, argc - 1, argv + 1);
	_monitor_call((void *)addr);

	printf ("## Application terminated, rc = 0x%lX\n", rc);
	return 0;
}

/* -------------------------------------------------------------------- */

U_BOOT_CMD(
	boots, CONFIG_SYS_MAXARGS, 1,	do_boots,
	"start secure application at address 'addr'",
	"addr [arg ...]\n    - start application at address 'addr'\n"
	"      passing 'arg' as arguments"
);
