/*
 * monitor - Monitor Boot Code for ARM platforms
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

.arch_extension sec

.globl _monitor_init
_monitor_init:
    push {r1, r10, r11, lr}
#TZPC setup
    ldr r10, _tzpc_base
    mov r11, #0x0
    str r11, [r10]

    ldr r10, _tzpc_decprot0
    ldr r11, _tzpc_decprot0_set
    str r11, [r10, +#0x4]

    ldr r10, _tzpc_decprot0
    ldr r11, _tzpc_decprot1_set
    str r11, [r10, +#0x10]

    ldr r10, _tzpc_decprot0
    mov r11, #0x7
    str r11, [r10, +#0x1c]
#TZASC setup
    ldr r10, _tzasc_region_base
    mov r11, #0xf0000000
    str r11, [r10, +#0x8]

    ldr r10, _tzasc_region_base
    ldr r11, _tzasc_reg1_set
    str r11, [r10, +#0x18]

    ldr r10, _tzasc_region_base
    mov r11, #0x10000000
    str r11, [r10, +#0x20]

    ldr r10, _tzasc_region_base
    ldr r11, _tzasc_reg2_set
    str r11, [r10, +#0x28]

    ldr r10, _tzasc_region_base
    mov r11, #0x40000000
    str r11, [r10, +#0x30]

    ldr r10, _tzasc_region_base
    ldr r11, _tzasc_reg3_set
    str r11, [r10, +#0x38]
    
    mov r11, sp
    /* switch to monitor mode */
    cps 0x16
    /* SCR -> NS bit */
    mov r1, #0x11
    mcr p15, 0, r1, c1, c1, 0
    /* switch to svc32 mode */
    cps 0x13
    mov sp, r11
    pop {r1, r10, r11, lr}
    mov pc, lr

_tzpc_base:
    .word 0x100E6000
_tzpc_decprot0:
    .word 0x100E6800
_tzasc_region_base:
    .word 0x100EC100
_tzpc_decprot0_set:
    .word 0x47bf
_tzpc_decprot1_set:
    .word 0x377
_tzasc_reg1_set:
    .word 0xf000e73f
_tzasc_reg2_set:
    .word 0xf0000021
_tzasc_reg3_set:
    .word 0xf000f439

workspace:
	.space 64

/* Monitor call
r0 - Monitor Jump address
*/
.globl _monitor_call
_monitor_call:
    push {r0, r4}
    mov r4, r0
// r0 = pointer to workspace
    adr r0, workspace
//Push all registers to workspace
    stmea r0!,{r1-r14}
    adr r2, ret
    ldr r1, _magic_boot
    smc #0
ret:
    adr r0, workspace
// Reload workspace
    ldmfd r0!,{r1-r14}
    pop {r0, r4}
    bx lr

_magic_boot:
    .word 0XDEAD100C

.align	5
.globl _monitor_base
_monitor_base:
#RESET
    b    .
#UNDEF
    b    .
#SMC
    b   _monitor_load_app
#PFABORT
    b    .
#DABORT
    b    .
#RESERVED
    b    .
#IRQ
    b   .
#VECTOR
    b   .

_monitor_load_app:
    /* SCR -> NS bit */
    mov r3, #0x10
    mcr p15, 0, r3, c1, c1, 0
    /* switch to svc32 mode */
    cps 0x13
    movs    pc, r4

.global _end_monitor_base

