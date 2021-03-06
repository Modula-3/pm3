(* Copyright (C) 1990, Digital Equipment Corporation.         *)
(* All rights reserved.                                       *)
(* See the file COPYRIGHT for a full description.             *)
(*                                                            *)
(* Last modified on Fri Apr 29 14:28:30 PDT 1994 by kalsow    *)
(*      modified on Sat Apr 16 by rrw1000@hermes.cam.ac.uk    *)
(*      modified on Mon Mar 09 19:04:05 PST 1992 by muller    *)

UNSAFE MODULE Umsg;

PROCEDURE MSG_LOCK (<*UNUSED*> x: UNTRACED REF struct_msqid_ds) =
  BEGIN
(*
    WITH mode = x.msg_perm.mode DO
      WHILE Word.And (mode, MSG_LCK) # 0 DO
        mode := Word.Or (mode, MSG_WANT);
        Unix.sleep (x.msg_first, PMSG); END;
      mode := Word.Or (mode, MSG_LCK); END;
*)
  END MSG_LOCK;

PROCEDURE MSG_UNLOCK (<*UNUSED*> x: UNTRACED REF struct_msqid_ds) =
  BEGIN
(*
    WITH mode = x.msg_perm.mode DO
      IF Word.And (mode, MSG_LCK) = 0 THEN
        Unix.panic (M3toC.TtoS ("MSG_UNLOCK")); END;
      IF Word.And (mode, MSG_WANT) # 0 THEN
        Ultrix.wakeup (x.msg_first); END;
      mode := Word.And (mode, Word.Not (Word.Or (MSG_WANT, MSG_LCK))); END;
*)
  END MSG_UNLOCK;

BEGIN
END Umsg.

