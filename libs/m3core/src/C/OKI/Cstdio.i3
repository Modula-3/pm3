(* Copyright (C) 1990, Digital Equipment Corporation.         *)
(* All rights reserved.                                       *)
(* See the file COPYRIGHT for a full description.             *)
(*                                                            *)
(* Last modified on Thu Sep 23 09:03:27 PDT 1993 by kalsow    *)
(*      modified on Wed Mar 13 00:21:05 1991 by muller        *)

INTERFACE Cstdio; (* for OKI *)

CONST 
  N_STATIC_IOBS = 3;
  IOEOF  = 8_20;

TYPE
  Base = [2..16];
  iobuf = RECORD 
            cnt: INTEGER;
            ptr: UNTRACED REF CHAR;
            base: UNTRACED REF CHAR;
            bufsiz: INTEGER;
            flag: [0..16_FFFF];
            file: [0..16_FF]; END;

<*EXTERNAL "_iob"*> VAR iob: ARRAY [0..N_STATIC_IOBS - 1] OF iobuf;
<*EXTERNAL "_flsbuf"*> PROCEDURE flsbuf (c: CHAR; f: UNTRACED REF iobuf);
<*EXTERNAL "_filbuf"*> PROCEDURE filbuf (f: UNTRACED REF iobuf): CHAR;
<*EXTERNAL "ungetc"*>  PROCEDURE ungetc (c: CHAR; f: UNTRACED REF iobuf);
<*EXTERNAL "fflush"*> PROCEDURE flush (f: UNTRACED REF iobuf);

END Cstdio.

