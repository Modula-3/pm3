(* Copyright (C) 1993, Digital Equipment Corporation            *)
(* All rights reserved.                                         *)
(* See the file COPYRIGHT for a full description.               *)
(*                                                              *)
(* File: Target.m3                                              *)
(* Last Modified On Tue Jan 24 09:58:43 PST 1995 By kalsow      *)
(*      Modified On Fri Dec  9 12:56:47 PST 1994 By Olaf Wagner *)

MODULE Target;

IMPORT Text, TargetMap, M3RT;

CONST
  Systems = ARRAY OF TEXT {
    (*  0 *) "AIX386",
    (*  1 *) "ALPHA_OSF",
    (*  2 *) "AP3000",
    (*  3 *) "ARM",
    (*  4 *) "DS3100",
    (*  5 *) "FreeBSD",
    (*  6 *) "FreeBSD2",
    (*  7 *) "HP300",
    (*  8 *) "HPPA",
    (*  9 *) "IBMR2",
    (* 10 *) "IBMRT",
    (* 11 *) "IRIX5",
    (* 12 *) "LINUX",
    (* 13 *) "LINUXELF",
    (* 14 *) "NEXT",
    (* 15 *) "NT386",
    (* 16 *) "NT386GNU",
    (* 17 *) "OKI",
    (* 18 *) "SEQUENT",
    (* 19 *) "SOLgnu",
    (* 20 *) "SOLsun",
    (* 21 *) "SPARC",
    (* 22 *) "SUN3",
    (* 23 *) "SUN386",
    (* 24 *) "UMAX",
    (* 25 *) "VAX"
  };

VAR (*CONST*)
  CCs : REF ARRAY OF CallingConvention;

PROCEDURE Init (system: TEXT): BOOLEAN =
  CONST FF = 16_ffff;
  VAR sys := 0;  max_align := 64;
  BEGIN
    (* lookup the system *)
    IF (system = NIL) THEN RETURN FALSE END;
    WHILE NOT Text.Equal (system, Systems[sys]) DO
      INC (sys);  IF (sys >= NUMBER (Systems)) THEN RETURN FALSE END;
    END;
    System_name := Systems[sys];

    (* build a generic 32-bit/IEEE system description *)

    Address.cg_type  := CGType.Addr;
    Address.size     := 32;
    Address.align    := 32;
    Address.min.x    := IChunks { 00, 00, 00, 00 };
    Address.max.x    := IChunks { FF, FF, 00, 00 };

    Int_A.cg_type    := CGType.Int_A;
    Int_A.size       := 8;
    Int_A.align      := 8;
    Int_A.min.x      := IChunks { 16_ff80, FF, FF, FF };
    Int_A.max.x      := IChunks { 16_007f, 00, 00, 00 };

    Int_B.cg_type    := CGType.Int_B;
    Int_B.size       := 16;
    Int_B.align      := 16;
    Int_B.min.x      := IChunks { 16_8000, FF, FF, FF };
    Int_B.max.x      := IChunks { 16_7fff, 00, 00, 00 };

    Int_C.cg_type    := CGType.Int;
    Int_C.size       := 32;
    Int_C.align      := 32;
    Int_C.min.x      := IChunks { 00, 16_8000, FF, FF };
    Int_C.max.x      := IChunks { FF, 16_7fff, 00, 00 };

    Int_D            := Int_C;
    Integer          := Int_C;

    Word_A.cg_type   := CGType.Word_A;
    Word_A.size      := 8;
    Word_A.align     := 8;
    Word_A.min.x     := IChunks { 16_0000, 00, 00, 00 };
    Word_A.max.x     := IChunks { 16_00ff, 00, 00, 00 };

    Word_B.cg_type   := CGType.Word_B;
    Word_B.size      := 16;
    Word_B.align     := 16;
    Word_B.min.x     := IChunks { 00, 00, 00, 00 };
    Word_B.max.x     := IChunks { FF, 00, 00, 00 };

    Word_C.cg_type   := CGType.Word;
    Word_C.size      := 32;
    Word_C.align     := 32;
    Word_C.min.x     := IChunks { 00, 16_0000, 00, 00 };
    Word_C.max.x     := IChunks { FF, 16_7fff, 00, 00 };

    Word_D           := Word_C;
    Char             := Word_A;

    Void.cg_type     := CGType.Void;
    Void.size        := 0;
    Void.align       := Byte;
    Void.min.x       := IChunks { 0, 0, 0, 0 };
    Void.max.x       := IChunks { 0, 0, 0, 0 };

    Real.cg_type     := CGType.Reel;
    Real.pre         := Precision.Short;
    Real.size        := 32;
    Real.align       := 32;
    Real.min         := Float { Precision.Short, 0, -3.40282346638528860x+38 };
    Real.max         := Float { Precision.Short, 0,  3.40282346638528860x+38 };

    Longreal.cg_type := CGType.LReel;
    Longreal.pre     := Precision.Long;
    Longreal.size    := 64;
    Longreal.align   := 64;
    Longreal.min     := Float { Precision.Long, 0,-1.79769313486231570x+308 };
    Longreal.max     := Float { Precision.Long, 0, 1.79769313486231570x+308 };

    Extended.cg_type := CGType.XReel;
    Extended.pre     := Precision.Extended;
    Extended.size    := 64;
    Extended.align   := 64;
    Extended.min     := Float{Precision.Extended, 0,-1.79769313486231570x+308};
    Extended.max     := Float{Precision.Extended, 0, 1.79769313486231570x+308};

    Alignments[0] := 8;
    Alignments[1] := 16;
    Alignments[2] := 32;
    Alignments[3] := 64;

    CCs := NIL;

    (* add the system-specific customization *)
    CASE sys OF
    |  0 => (* AIX386 *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 25 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  1 => (* ALPHA_OSF *)
                 Int_C.cg_type    := CGType.Int_C;
                 Word_C.cg_type   := CGType.Word_C;
                 Word_C.max.x[1]  := FF;

                 Int_D.cg_type    := CGType.Int_D;
                 Int_D.size       := 64;
                 Int_D.align      := 64;
                 Int_D.min.x      := IChunks { 00, 00, 00, 16_8000 };
                 Int_D.max.x      := IChunks { FF, FF, FF, 16_7fff };

                 Word_D.cg_type   := CGType.Word_D;
                 Word_D.size      := 64;
                 Word_D.align     := 64;
                 Word_D.min.x     := IChunks { 00, 00, 00, 00 };
                 Word_D.max.x     := IChunks { FF, FF, FF, FF };

                 Integer          := Int_D;
                 Address          := Word_D;
                 Address.cg_type  := CGType.Addr;

                 max_align                 := 64;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 16_400000;
                 Jumpbuf_size              := 84 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := TRUE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := TRUE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  2 => (* AP3000 *)
                 max_align                 := 16;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 16;
                 Bitfield_can_overlap      := TRUE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 83 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  3 => (* ARM *)
                 max_align                 := 32;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 32;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 16 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  4 => (* DS3100 *)
                 max_align                 := 64;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 16_400000;
                 Jumpbuf_size              := 84 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := TRUE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := TRUE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  5, 6 => (* FreeBSD, FreeBSD2 *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 4096 * Char.size;
                 Jumpbuf_size              := 11 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  7 => (* HP300 *)
                 max_align                 := 16;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 16;
                 Bitfield_can_overlap      := TRUE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 100 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  8 => (* HPPA *)
                 max_align                 := 64;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 16;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 16_1000;
                 Jumpbuf_size              := 53 * Address.size;
                 Jumpbuf_align             := max_align;
                 Fixed_frame_size          := 8 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := FALSE;
                 EOL                       := "\n";

    |  9 => (* IBMR2 *)
                 max_align                 := 32;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 32;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 65 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 10 => (* IBMRT *)
                 max_align                 := 32;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 17 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  11 => (* IRIX5 *)
                 max_align                 := 64;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 16_400000;
                 Jumpbuf_size              := 28 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    |  12, 13 => (* LINUX, LINUXELF *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 8 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "__setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 14 => (* NEXT *)
                 max_align                 := 16;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 16;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 39 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 15, 16 => (* NT386, NT386GNU *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 4096;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 0;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;

                 IF sys = 15 THEN 
                   Jumpbuf_size            := 8 * Address.size;
                   Setjmp                  := "_setjmp";
                 ELSE
                   Jumpbuf_size            := 52 * Address.size;
                   Setjmp                  := "setjmp";
                 END;

                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := FALSE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\r\n";
                 (* initial experiments indicate that the first 64K of
                    a process's memory on NT are "free" and unreadable.
                    --- WKK  9/9/94 *)

                 CCs := NEW (REF ARRAY OF CallingConvention, 9);
                 NTCall (0, "C",          0, sys = 16); (* __cdecl *)
                 NTCall (1, "WINAPI",     1, sys = 16); (* __stdcall *)
                 NTCall (2, "CALLBACK",   1, sys = 16); (* __stdcall *)
                 NTCall (3, "WINAPIV",    0, sys = 16); (* __cdecl *)
                 NTCall (4, "APIENTRY",   1, sys = 16); (* __stdcall *)
                 NTCall (5, "APIPRIVATE", 1, sys = 16); (* __stdcall *)
                 NTCall (6, "PASCAL",     1, sys = 16); (* __stdcall *)
                 NTCall (7, "__cdecl",    0, sys = 16); (* __cdecl *)
                 NTCall (8, "__stdcall",  1, sys = 16); (* __stdcall *)

    | 17 => (* OKI *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 32;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 22 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 18 => (* SEQUENT *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 84 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 19, 20 => (* SOLgnu, SOLsun *)
                 max_align                 := 64;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 8192;
                 Jumpbuf_size              := 19 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 20 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := TRUE;
                 Setjmp                    := "setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 21 => (* SPARC *)
                 max_align                 := 64;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 8192;
                 Jumpbuf_size              := 10 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 20 * Address.size;
                 Guard_page_size           := 4096 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 22 => (* SUN3 *)
                 max_align                 := 16;
                 Little_endian             := FALSE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 16;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 79 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 1024 * Char.size;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 23 => (* SUN386 *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := FALSE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 8 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 24 => (* UMAX *)
                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 10 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 4 * Address.size;
                 Guard_page_size           := 0;
                 All_floats_legal          := TRUE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    | 25 => (* VAX *)
                 Real.min.fraction     := -1.70111x+38;
                 Real.max.fraction     := -1.70111x+38;
                 Longreal.min.fraction := -1.70111x+38;
                 Longreal.max.fraction := -1.70111x+38;
                 Extended.min.fraction := -1.70111x+38;
                 Extended.max.fraction := -1.70111x+38;

                 max_align                 := 32;
                 Little_endian             := TRUE;
                 PCC_bitfield_type_matters := TRUE;
                 Structure_size_boundary   := 8;
                 Bitfield_can_overlap      := FALSE;
                 First_readable_addr       := 0;
                 Jumpbuf_size              := 10 * Address.size;
                 Jumpbuf_align             := Address.align;
                 Fixed_frame_size          := 12 * Address.size;
                 Guard_page_size           := 1024 * Char.size;
                 All_floats_legal          := FALSE;
                 Has_stack_walker          := FALSE;
                 Setjmp                    := "_setjmp";
                 Checks_integer_ops        := FALSE;
                 Global_handler_stack      := TRUE;
                 Aligned_procedures        := TRUE;
                 EOL                       := "\n";

    ELSE RETURN FALSE;
    END;

    IF (CCs = NIL) THEN
      CCs := NEW (REF ARRAY OF CallingConvention, 1);
      VAR cc := NEW (CallingConvention);  BEGIN
        CCs[0] := cc;
        cc.name               := "C";
        cc.m3cg_id            := 0;
        cc.args_left_to_right := TRUE;
        cc.results_on_left    := FALSE;
        cc.standard_structs   := TRUE;
      END;
    END;
    DefaultCall := CCs[0];


    <*ASSERT Integer.size MOD ChunkSize = 0 *>
    last_chunk := Integer.size DIV ChunkSize - 1;

    (* fill in the "bytes" and "pack" fields *)
    FixI (Address, max_align);
    FixI (Integer, max_align);
    FixF (Real, max_align);
    FixF (Longreal, max_align);
    FixF (Extended, max_align);
    FixI (Int_A, max_align);
    FixI (Int_B, max_align);
    FixI (Int_C, max_align);
    FixI (Int_D, max_align);
    FixI (Word_A, max_align);
    FixI (Word_B, max_align);
    FixI (Word_C, max_align);
    FixI (Word_D, max_align);
    FixI (Void, max_align);
    FixI (Char, max_align);

    (* sets are always treated as an array of integers *)    
    Set_grain := Integer.size;
    Set_align := Integer.align;

    (* fix the alignments *)
    FOR i := FIRST (Alignments) TO LAST (Alignments) DO
      Alignments[i] := MIN (Alignments[i], max_align);
    END;

    (* initialize the other target-specific modules *)
    TargetMap.Init ();
    M3RT.Init ();

    RETURN TRUE;
  END Init;

PROCEDURE NTCall (x: INTEGER;  nm: TEXT;  id: INTEGER; gnuWin32: BOOLEAN) =
  BEGIN
    CCs[x] := NEW (CallingConvention,
                     name := nm,
                     m3cg_id := id,
                     args_left_to_right := FALSE,
                     results_on_left := TRUE,
                     standard_structs := FALSE);
    IF gnuWin32 THEN
      CCs[x].args_left_to_right := TRUE;
      CCs[x].results_on_left := TRUE;
      CCs[x].standard_structs := TRUE;
    END;
  END NTCall;

PROCEDURE FixI (VAR i: Int_type;  max_align: INTEGER) =
  BEGIN
    i.align := MIN (i.align, max_align);
    i.bytes := i.size DIV Byte;
    i.pack  := (i.size + i.align - 1) DIV i.align * i.align;
  END FixI;

PROCEDURE FixF (VAR f: Float_type;  max_align: INTEGER) =
  BEGIN
    f.align := MIN (f.align, max_align);
    f.bytes := f.size DIV Byte;
    (* f.pack  := (f.size + f.align - 1) DIV f.align * f.align; *)
  END FixF;

PROCEDURE FindConvention (nm: TEXT): CallingConvention =
  VAR cc: CallingConvention;
  BEGIN
    FOR i := 0 TO LAST (CCs^) DO
      cc := CCs[i];
      IF (cc # NIL) AND Text.Equal (nm, cc.name) THEN RETURN cc; END;
    END;
    RETURN NIL;
  END FindConvention;

PROCEDURE ConventionFromID (id: INTEGER): CallingConvention =
  VAR cc: CallingConvention;
  BEGIN
    FOR i := 0 TO LAST (CCs^) DO
      cc := CCs[i];
      IF (cc # NIL) AND (cc.m3cg_id = id) THEN RETURN cc; END;
    END;
    RETURN NIL;
  END ConventionFromID;

BEGIN
END Target.

