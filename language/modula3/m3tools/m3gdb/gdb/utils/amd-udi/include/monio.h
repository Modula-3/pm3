/* @(#)monio.h	5.18 93/07/30 16:40:04, Srini, AMD */
/******************************************************************************
 * Copyright 1991 Advanced Micro Devices, Inc.
 *
 * This software is the property of Advanced Micro Devices, Inc  (AMD)  which
 * specifically  grants the user the right to modify, use and distribute this
 * software provided this notice is not removed or altered.  All other rights
 * are reserved by AMD.
 *
 * AMD MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, WITH REGARD TO THIS
 * SOFTWARE.  IN NO EVENT SHALL AMD BE LIABLE FOR INCIDENTAL OR CONSEQUENTIAL
 * DAMAGES IN CONNECTION WITH OR ARISING FROM THE FURNISHING, PERFORMANCE, OR
 * USE OF THIS SOFTWARE.
 *
 * So that all may benefit from your experience, please report  any  problems
 * or  suggestions about this software to the 29K Technical Support Center at
 * 800-29-29-AMD (800-292-9263) in the USA, or 0800-89-1131  in  the  UK,  or
 * 0031-11-1129 in Japan, toll free.  The direct dial number is 512-462-4118.
 *
 * Advanced Micro Devices, Inc.
 * 29K Support Products
 * Mail Stop 573
 * 5900 E. Ben White Blvd.
 * Austin, TX 78741
 * 800-292-9263
 *****************************************************************************
 *      Engineer: Srini Subramanian.
 *****************************************************************************
 * This header file declares the I/O functions of the monitor.
 *****************************************************************************
 */
#ifndef	_IO_H_INCLUDED_
#define	_IO_H_INCLUDED_


#define BUFFER_SIZE        256

/*
** Definitions for unprintable ASCII
*/

#define BELL           '\007'  /* 0x07 */
#define RET            '\015'  /* 0x0d */
#define LF             '\012'  /* 0x0a */
#define CTRL_C         '\003'  /* 0x03 */
#define BS             '\010'  /* 0x08 */
#define ESC            '\033'  /* 0x1b */
#define DEL            '\177'  /* 0x7f */

#endif /* _IO_H_INCLUDED_ */
