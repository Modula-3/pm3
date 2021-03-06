(* Copyright (C) 1990, Digital Equipment Corporation           *)
(* All rights reserved.                                        *)
(* See the file COPYRIGHT for a full description.              *)
(*                                                             *)
(* Last modified on Thu Dec 16 08:18:42 PST 1993 by kalsow     *)
(*      modified on Thu Jun 25 18:20:47 PDT 1992 by muller     *)

UNSAFE INTERFACE RTExFrame;

IMPORT Csetjmp, RT0;

(* This interface defines the low-level routines and data structures
   used by the exception runtime.
*)

(*----------------------------------------- compiler generated descriptors --*)

TYPE
  ScopeKind = { Except, ExceptElse,
                Finally, FinallyProc,
                Raises, RaisesNone,
                Lock };

TYPE
  Frame = UNTRACED REF EF;

TYPE
  ExceptionList = UNTRACED REF (*ARRAY OF*) RT0.ExceptionUID;
  FinallyProc   = PROCEDURE (VAR a: RT0.RaiseActivation) RAISES ANY;

TYPE (* RaisesNone *)
  EF = RECORD
    next  : Frame;
    class : INTEGER;    (* ORD(ScopeKind) *)
  END;

TYPE (* Except, ExceptElse, Finally *)
  PF1 = UNTRACED REF EF1;
  EF1 = RECORD
    next      : Frame;
    class     : INTEGER;    (* ORD(ScopeKind) *)
    handles   : ExceptionList;    (* NIL-terminated list of exceptions handled *)
    info      : RT0.RaiseActivation;   (* current exception being dispatched *)
    jmpbuf    : Csetjmp.jmp_buf;
  END;

TYPE (* FinallyProc *)
  PF2 = UNTRACED REF EF2;
  EF2 = RECORD
    next    : Frame;
    class   : INTEGER;      (* ORD(ScopeKind) *)
    handler : ADDRESS;      (* the procedure *)
    frame   : ADDRESS;      (* static link for the handler *)
  END;

TYPE (* Raises *)
  PF3 = UNTRACED REF EF3;
  EF3 = RECORD
    next    : Frame;
    class   : INTEGER;  (* ORD(ScopeKind) *)
    raises  : ExceptionList;  (*  NIL-terminated list of exceptions allowed *)
  END;

TYPE (* Lock *)
  PF4 = UNTRACED REF EF4;
  EF4 = RECORD
    next    : Frame;
    class   : INTEGER;  (* ORD(ScopeKind) *)
    mutex   : MUTEX;    (* the locked mutex *)
  END;

END RTExFrame.

