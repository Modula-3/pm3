(* Copyright (C) 1992, Digital Equipment Corporation                         *)
(* All rights reserved.                                                      *)
(* See the file COPYRIGHT for a full description.                            *)
(*                                                                           *)
(* Last modified on Sat Jan  7 14:33:32 PST 1995 by kalsow                   *)
(*      modified on Tue Mar 24 21:10:33 PST 1992 by muller                   *)
(*      modified on Tue Feb 11 22:04:30 PST 1992 by nichols@parc.xerox.com   *)

(* Little-endian version. *)

UNSAFE MODULE Uin EXPORTS Uin;
(* Only unsafe because it needs Usocket.AF_INET and Usocket is unsafe. *)

FROM Utypes IMPORT u_char, in_addr_t, in_port_t;
IMPORT Usocket, Word;

PROCEDURE IN_CLASSA(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_800000, 8)) = 0;
  END IN_CLASSA;

PROCEDURE IN_CLASSB(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_c00000, 8)) = Word.Shift(16_800000, 8);
  END IN_CLASSB;

PROCEDURE IN_CLASSC(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_e00000, 8)) = Word.Shift(16_c00000, 8);
  END IN_CLASSC;

PROCEDURE IN_CLASSD(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_f00000, 8)) = Word.Shift(16_e00000, 8);
  END IN_CLASSD;

PROCEDURE IN_MULTICAST(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN IN_CLASSD(i);
  END IN_MULTICAST;

PROCEDURE IN_EXPERIMENTAL(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_e00000, 8)) = Word.Shift(16_e00000, 8);
  END IN_EXPERIMENTAL;

PROCEDURE IN_BADCLASS(i: INTEGER): BOOLEAN =
  BEGIN
    RETURN Word.And(i, Word.Shift(16_f00000, 8)) = Word.Shift(16_f00000, 8);
  END IN_BADCLASS;

PROCEDURE IN_SET_LOOPBACK_ADDR(a: struct_sockaddr_in_star) =
  BEGIN
    a.sin_addr.s_addr := htonl(INADDR_LOOPBACK);
    a.sin_family := Usocket.AF_INET;
  END IN_SET_LOOPBACK_ADDR;

TYPE
  A = RECORD a, b, c, d: u_char; END;
  B = RECORD d, c, b, a: u_char; END;

  C = RECORD a, b: u_char; END;
  D = RECORD b, a: u_char; END;


PROCEDURE ntohl(x: in_addr_t): in_addr_t =
  BEGIN
    RETURN LOOPHOLE (B { a := LOOPHOLE (x, A).a, 
      	      	         b := LOOPHOLE (x, A).b,
                         c := LOOPHOLE (x, A).c,
                         d := LOOPHOLE (x, A).d},  in_addr_t);
  END ntohl;

PROCEDURE ntohs(x: in_port_t): in_port_t =
  BEGIN
    RETURN LOOPHOLE (D { a := LOOPHOLE (x, C).a, 
      	      	         b := LOOPHOLE (x, C).b},  in_port_t);
  END ntohs;

PROCEDURE htonl(x: in_addr_t): in_addr_t =
  BEGIN
    RETURN LOOPHOLE (A { a := LOOPHOLE (x, B).a, 
      	      	         b := LOOPHOLE (x, B).b,
                         c := LOOPHOLE (x, B).c,
                         d := LOOPHOLE (x, B).d},  in_addr_t);
  END htonl;

PROCEDURE htons(x: in_port_t): in_port_t =
  BEGIN
    RETURN LOOPHOLE (C { a := LOOPHOLE (x, D).a, 
      	      	         b := LOOPHOLE (x, D).b},  in_port_t);
  END htons;

BEGIN
END Uin.
