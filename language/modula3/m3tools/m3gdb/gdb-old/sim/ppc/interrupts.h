/*  This file is part of the program psim.

    Copyright (C) 1994-1995, Andrew Cagney <cagney@highland.com.au>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 
    */


#ifndef _INTERRUPTS_H_
#define _INTERRUPTS_H_

/* Interrupts:

   The code below handles two different types of interrupts.
   Synchronous and Asynchronous.

   Synchronous:

   Interrupts that must immediately force either an abort or restart
   of a current instruction are implemented by forcing an instruction
   restart. (or to put it another way, long jump).  In looking at the
   code it may occure to you that, for some interrupts, they could
   return instead of restarting the cpu (eg system_call).  While true
   (it once was like that) I've decided to make the behavour of all
   interrupt routines roughly identical.

   Because, a cpu's recorded state (ie what is in the cpu structure)
   is allowed to lag behind the cpu's true current state (eg PC not
   updated) sycnronous interrupt handers are parameterized with the
   the cpu being interrupted so that, as part of moddeling the
   interrupt, the cpu's state can be updated.

   Asynchronous:

   Interrupts such as reset or external exception are delivered using
   more normal (returning) functions.  It is assumed that these
   functions are called out side of the normal processor execution
   cycle. */


/* Software generated interrupts.

   The below are generated by software driven events.  For instance,
   an invalid instruction or access (virtual or physical) to an
   invalid address */

typedef enum {
  direct_store_storage_interrupt,
  hash_table_miss_storage_interrupt,
  protection_violation_storage_interrupt,
  earwax_violation_storage_interrupt,
  segment_table_miss_storage_interrupt,
  earwax_disabled_storage_interrupt,
  vea_storage_interrupt,
} storage_interrupt_reasons;


INLINE_INTERRUPTS\
(void) data_storage_interrupt
(cpu *processor,
 unsigned_word cia,
 unsigned_word ea,
 storage_interrupt_reasons reason,
 int is_store);

INLINE_INTERRUPTS\
(void) instruction_storage_interrupt
(cpu *processor,
 unsigned_word cia,
 storage_interrupt_reasons reason);

INLINE_INTERRUPTS\
(void) alignment_interrupt
(cpu *processor,
 unsigned_word cia,
 unsigned_word ra);

typedef enum {
  floating_point_enabled_program_interrupt,
  illegal_instruction_program_interrupt,
  privileged_instruction_program_interrupt,
  trap_program_interrupt,
  nr_program_interrupt_reasons
} program_interrupt_reasons;

INLINE_INTERRUPTS\
(void) program_interrupt
(cpu *processor,
 unsigned_word cia,
 program_interrupt_reasons reason);

INLINE_INTERRUPTS\
(void) floating_point_unavailable_interrupt
(cpu *processor,
 unsigned_word cia);

INLINE_INTERRUPTS\
(void) system_call_interrupt
(cpu *processor,
 unsigned_word cia);

INLINE_INTERRUPTS\
(void) floating_point_assist_interrupt
(cpu *processor,
 unsigned_word cia);

INLINE_INTERRUPTS\
(void) machine_check_interrupt
(cpu *processor,
 unsigned_word cia);

/* Hardware generated interrupts:

   These asynchronous hardware generated interrupts may be called at
   any time.  It is the responsibility of this (the interrupts) module
   to ensure that interrupts are delivered correctly (when possible).
   The delivery of these interrupts is controlled by the MSR's
   external interrupt enable bit.  When ever the MSR's value is
   changed, the processor must call the check_masked_interrupts()
   function in case delivery has been made possible.

   decrementer_interrupt is `edge' sensitive.  Multiple edges arriving
   before the first edge has been delivered result in only one
   interrupt.

   external_interrupt is `level' sensitive.  An external interrupt
   will only be delivered when the external interrupt port is
   `asserted'. While interrupts are disabled, the external interrupt
   can be asserted and then de-asserted without an interrupt
   eventually being delivered. */

enum {
  external_interrupt_pending = 1,
  decrementer_interrupt_pending = 2,
};

typedef struct _interrupts {
  event_entry_tag delivery_scheduled;
  int pending_interrupts;
} interrupts;

INLINE_INTERRUPTS\
(void) check_masked_interrupts
(cpu *processor);

INLINE_INTERRUPTS\
(void) decrementer_interrupt
(cpu *processor);

INLINE_INTERRUPTS\
(void) external_interrupt
(cpu *processor,
 int is_asserted);

#endif /* _INTERRUPTS_H_ */