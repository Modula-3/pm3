(* Copyright (C) 1993, Digital Equipment Corporation           *)
(* All rights reserved.                                        *)
(* See the file COPYRIGHT for a full description.              *)
(*                                                             *)
(* Portions Copyright 1996-2000, Critical Mass, Inc.           *)
(* See file COPYRIGHT-CMASS for details.                       *)

(*  Modula-3 code generator operations

   This interface defines the myriad operations that are available
   on an M3CG.T.
*)

INTERFACE M3CG_Ops;

IMPORT Target, M3CG;
FROM M3CG IMPORT Type, MType, IType, RType, AType, ZType, Sign;
FROM M3CG IMPORT Name, Var, Proc, Alignment, TypeUID, Label;
FROM M3CG IMPORT Frequency, CallingConvention, CompareOp, ConvertOp;
FROM M3CG IMPORT BitSize, ByteSize, BitOffset, ByteOffset, RuntimeError;

TYPE
  ErrorHandler = PROCEDURE (msg: TEXT);

REVEAL
  M3CG.T <: Public;

TYPE
  Public = OBJECT
(*------------------------------------------------ READONLY configuration ---*)

child: M3CG.T := NIL;
(* The default methods simply call the corresponding method in 'child',
   hence a vanilla 'M3CG.T' can be used as a filter where you override
   only the methods of interest. *)

METHODS
(*----------------------------------------------------------- ID counters ---*)

next_label (n: INTEGER := 1): Label;
(* reserve 'n' consecutive labels and return the first one *)

(*------------------------------------------------ READONLY configuration ---*)

set_error_handler (p: ErrorHandler);
(* 'p' is called to communicate failures (i.e. creating a stack or module
   that's too big) back to the front-end.  Client or implementation
   programming errors (bugs) result in crashes. *)

(*----------------------------------------------------- compilation units ---*)

begin_unit (optimize: INTEGER := 0);
(* called before any other method to initialize the compilation unit. *)

end_unit ();
(* called after all other methods to finalize the unit and write the
   resulting object.  *)

import_unit (n: Name);
export_unit (n: Name);
(* note that the current compilation unit imports/exports the interface 'n' *)

(*------------------------------------------------ debugging line numbers ---*)

set_source_file (file: TEXT);
set_source_line (line: INTEGER);
(* Sets the current source file and line number.  Subsequent statements
   and expressions are associated with this source location. *)

(*------------------------------------------- debugging type declarations ---*)

(* The debugging information for a type is identified by a gloablly unique
   32-bit id generated by the front-end.  The following methods generate
   the symbol table entries needed to describe Modula-3 types to the
   debugger. *)

declare_typename (t: TypeUID;  n: Name);
(* associate the name 'n' with type 't' *)

declare_array (t, index, elt: TypeUID;  s: BitSize);

declare_open_array (t, elt: TypeUID;  s: BitSize);
(* s describes the dope vector *)

declare_enum (t: TypeUID; n_elts: INTEGER;  s: BitSize);
declare_enum_elt (n: Name);

declare_packed  (t: TypeUID;  s: BitSize;  base: TypeUID);

declare_record (t: TypeUID;  s: BitSize;  n_fields: INTEGER);
declare_field (n: Name;  o: BitOffset;  s: BitSize;  t: TypeUID);

declare_set (t, domain: TypeUID;  s: BitSize);

declare_subrange (t,domain: TypeUID; READONLY min,max: Target.Int; s: BitSize);

declare_pointer (t, target: TypeUID;  brand: TEXT;  traced: BOOLEAN);
(* brand=NIL ==> t is unbranded *)

declare_indirect (t, target: TypeUID);
(* an automatically dereferenced pointer! (WITH variables, VAR formals, ...) *)

declare_proctype (t: TypeUID;  n_formals: INTEGER;
                  result: TypeUID;  n_raises: INTEGER;
                  cc: CallingConvention);
(* n_raises < 0 => RAISES ANY *)

declare_formal (n: Name;  t: TypeUID);

declare_raises (n: Name);

declare_object (t, super: TypeUID;  brand: TEXT;
                traced: BOOLEAN;  n_fields, n_methods: INTEGER;
                field_size: BitSize);
(* brand=NIL ==> t is unbranded *)

declare_method (n: Name;  signature: TypeUID);

declare_opaque (t, super: TypeUID);
(* TYPE t <: super *)

reveal_opaque (lhs, rhs: TypeUID);
(* REVEAL lhs = rhs *)

declare_exception (n: Name;  arg_type: TypeUID;  raise_proc: BOOLEAN;
                     base: Var;  offset: INTEGER);
(* declares an exception named 'n' identified with the address 'base+offset'
   that carries an argument of type 'arg_type'.  If 'raise_proc', then
   'base+offset+BYTESIZE(ADDRESS)' is a pointer to the procedure that
   packages the argument and calls the runtime to raise the exception. *)
   

(*--------------------------------------------------------- runtime hooks ---*)

set_runtime_proc (n: Name;  p: Proc);
(* declares 'n' as a runtime procedure 'p'.  *)

set_runtime_hook (n: Name;  v: Var;  o: ByteOffset);
(* declares 'n' as a runtime procedure available at location 'ADR(v)+o' *)

get_runtime_hook (n: Name;  VAR p: Proc;  VAR v: Var; VAR o: ByteOffset);
(* returns the location of the runtime symbol 'n' *)

(*------------------------------------------------- variable declarations ---*)

(* Clients must declare a variable before generating any statements or
   expressions that refer to it;  declarations of global variables and
   temps can be intermixed with generation of statements and expressions.

   In the declarations that follow:

|    n: Name            is the name of the variable.  If it's M3ID.NoID, the
|                         the back-end is free to choose its own unique name.
|    s: ByteSize        is the size in bytes of the declared variable
|    a: Alignment       is the minimum required alignment of the variable
|    t: Type            is the machine reprentation type of the variable
|    m3t: TypeUID       is the UID of the Modula-3 type of the variable,
|                       zero is used to represent "void" or "no type"
|    in_memory: BOOLEAN specifies whether the variable must have an address
|    exported: BOOLEAN  specifies whether the variable must be visible in
|                         other compilation units
|    init: BOOLEAN      indicates whether an explicit static initialization
|                         immediately follows this declaration.
|    up_level: BOOLEAN  specifies whether the variable is accessed from
|                         nested procedures.
|    f: Frequency       is the front-end estimate of how frequently the
|                         variable is accessed.

*)

import_global (n: Name;  s: ByteSize;  a: Alignment;  t: Type;
               m3t: TypeUID): Var;
(* imports the specified global variable. *)

declare_segment (n: Name;  m3t: TypeUID;  is_const: BOOLEAN): Var;
bind_segment (seg: Var;  s: ByteSize;  a: Alignment;  t: Type;
              exported, init: BOOLEAN);
(* Together declare_segment and bind_segment accomplish what
   declare_global("is_const = FALSE") or declare_constant("is_const=TRUE")
   does, but declare_segment gives the front-end a
   handle on the variable before its size, type, or initial values
   are known.  Every declared segment must be bound exactly once. *)

declare_global (n: Name;  s: ByteSize;  a: Alignment;  t: Type;
                m3t: TypeUID;  exported, init: BOOLEAN): Var;
(* declares a global variable. *)

declare_constant (n: Name;  s: ByteSize;  a: Alignment;  t: Type;
              m3t: TypeUID;  exported, init: BOOLEAN): Var;
(* declares a read-only global variable *)
 
declare_local (n: Name;  s: ByteSize;  a: Alignment;  t: Type;
               m3t: TypeUID;  in_memory, up_level: BOOLEAN;
               f: Frequency): Var;
(* declares a local variable.  Local variables must be declared in the
   procedure that contains them.  The lifetime of a local variable extends
   from the beginning to end of the closest enclosing begin_block/end_block. *)

declare_param (n: Name;  s: ByteSize;  a: Alignment;  t: Type;
               m3t: TypeUID;  in_memory, up_level: BOOLEAN;
               f: Frequency): Var;
(* declares a formal parameter.  Formals are declared in their lexical
   order immediately following the 'declare_procedure' or
   'import_procedure' that contains them.  *)

declare_temp (s: ByteSize;  a: Alignment;  t: Type;
              in_memory: BOOLEAN): Var;
(* declares an anonymous local variable.  Temps are declared
   and freed between their containing procedure's begin_procedure and
   end_procedure calls.  Temps are never referenced by nested procedures. *)

free_temp (v: Var);
(* releases the space occupied by temp 'v' so that it may be reused by
   other new temporaries. *)

(*---------------------------------------- static variable initialization ---*)

(* Global variables may be initialized only once.  All of their init_*
   calls must be bracketed by begin_init and end_init.  Within a begin/end
   pair, init_* calls must be made in ascending offset order.  Begin/end
   pairs may not be nested.  Any space in a global variable that's not
   explicitly initialized is zeroed.  *)

begin_init (v: Var);
end_init (v: Var);
(* must precede and follow any init calls *)

init_int (o: ByteOffset;  READONLY value: Target.Int;  t: Type);
(* initializes the integer static variable at 'ADR(v)+o' with
   the low order bits of 'value' which is of integer type 't'. *)

init_proc (o: ByteOffset;  value: Proc);
(* initializes the static variable at 'ADR(v)+o' with the address
   of procedure 'value'. *)

init_label (o: ByteOffset;  value: Label);
(* initializes the static variable at 'ADR(v)+o' with the address
   of the label 'value'.  *)

init_var (o: ByteOffset;  value: Var;  bias: ByteOffset);
(* initializes the static variable at 'ADR(v)+o' with the address
   of 'value+bias'.  *)

init_offset (o: ByteOffset;  var: Var);
(* initializes the static variable at 'ADR(v)+o' with the integer
   frame offset of the local variable 'var' relative to the frame
   pointers returned at runtime in RTStack.Frames *)

init_chars (o: ByteOffset;  value: TEXT);
(* initializes the static variable at 'ADR(v)+o' with the characters
   of 'value' *)

init_float (o: ByteOffset;  READONLY f: Target.Float);
(* initializes the static variable at 'ADR(v)+o' with the
   floating point value 'f' *)

(*------------------------------------------------------------ procedures ---*)

(* Clients compile a procedure by doing:

      proc := cg.declare_procedure (...)
        ...declare formals...
        ...declare locals...
      cg.begin_procedure (proc)
        ...generate statements of procedure...
      cg.end_procedure (...)

  Nested procedure bodies may be generated before their parent's
  begin_procedure, after their parent's end_procedure, or inline
  where they occur in the source.  If they are not inline,
  note_procedure_origin is used to mark their original source
  position.  Runtime flags passed to the front-end determine where
  nested procedure bodies are generated.  Back-ends are free to
  require any one of these three placements for nested procedures.
  (At the moment:  m3cc -> inline,  m3back -> after)
*)

import_procedure (n: Name;  n_params: INTEGER;  return: Type;
                  cc: CallingConvention): Proc;
(* declare and import the external procedure with name 'n' and 'n_params'
   formal parameters.  It must be a top-level (=0) procedure that returns
   values of type 'return'.  'lang' is the language specified in the
   procedure's <*EXTERNAL*> declaration.  The formal parameters are specified
   by the subsequent 'declare_param' calls. *)

declare_procedure (n: Name;  n_params: INTEGER;  return: Type;
                   lev: INTEGER;  cc: CallingConvention;
                   exported: BOOLEAN;  parent: Proc): Proc;
(* declare a procedure named 'n' with 'n_params' formal parameters
   at static level 'lev'.  Sets "current procedure" to this procedure.
   If the name n is M3ID.NoID, a new unique name will be supplied by the
   back-end.  The type of the procedure's result is specifed in 'return'.
   If the new procedure is a nested procedure (level > 1) then 'parent' is
   the immediately enclosing procedure, otherwise 'parent' is NIL.
   The formal parameters are specified by the subsequent 'declare_param'
   calls. *)

begin_procedure (p: Proc);
(* begin generating code for the procedure 'p'.  Sets "current procedure"
   to 'p'.  Implies a begin_block.  *)

end_procedure (p: Proc);
(* marks the end of the code for procedure 'p'.  Sets "current procedure"
   to NIL.  Implies an end_block.  *)

begin_block ();
end_block ();
(* marks the beginning and ending of nested anonymous blocks *)

note_procedure_origin (p: Proc);
(* note that nested procedure 'p's body occured at the current location
   in the source.  In particular, nested in whatever procedures,
   anonymous blocks, or exception scopes surround this point. *)

(*------------------------------------------------------------ statements ---*)

set_label (l: Label;  barrier: BOOLEAN := FALSE);
(* define 'l' to be at the current pc, if 'barrier', 'l' bounds an exception
   scope and no code is allowed to migrate past it. *)

jump (l: Label);
(* GOTO l *)

if_true  (t: IType;  l: Label;  f: Frequency);
(* tmp := s0.t; pop; IF (tmp # 0) GOTO l *)

if_false (t: IType;  l: Label;  f: Frequency);
(* tmp := s0.t; pop; IF (tmp = 0) GOTO l *)

if_compare (t: ZType;  op: CompareOp;  l: Label;  f: Frequency);
(*== compare(t, Int32, op); if_true(Int32, l,f)*)

case_jump (t: IType;  READONLY labels: ARRAY OF Label);
(* tmp := s0.t; pop; GOTO labels[tmp]  (NOTE: no range checking on s0.t) *)

exit_proc (t: Type);
(* Returns s0.t if t is not Void, otherwise returns no value. *)

(*------------------------------------------------------------ load/store ---*)
(* Note: When an Int8 or Int16 value is loaded, it is sign extended to
   either 32 or 64 bits.  When a Word8 or Word16 value is loaded, it is zero
   extended to either 32 or 64 bits.  When an Int8, Int16, Word8, or Word16
   value is stored, it is truncated to the indicated size.  There
   are no operations on 8 and 16 bit values except load/store.
   Arithmetic on these values is carried out on the corresponding
   sign-extended or zero-extended values.

   Note: all loads and stores are aligned according to the specified type.
*)

load (v: Var;  o: ByteOffset;  t: MType;  u: ZType);
(* push; s0.u := Mem [ ADR(v) + o ].t ;  The only allowed (t->u) conversions
   are {Int,Word}{8,16} -> {Int,Word}{32,64} and {Int,Word}32 -> {Int,Word}64.
   The source type, t, determines whether the value is sign-extended or
   zero-extended. *)

load_address (v: Var;  o: ByteOffset := 0);
(* push; s0.A := ADR(v) + o *)

load_indirect (o: ByteOffset;  t: MType;  u: ZType);
(* s0.u := Mem [s0.A + o].t  *)

store (v: Var;  o: ByteOffset;  t: ZType;  u: MType);
(* Mem [ ADR(v) + o : s ].u := s0.t; pop *)

store_indirect (o: ByteOffset;  t: ZType;  u: MType);
(* Mem [s1.A + o].u := s0.t; pop (2) *)

(*----------------------------------------------------------- expressions ---*)

(*  The code to evaluate expressions is generated by calling the
    procedures listed below.  Each procedure corresponds to an
    instruction for a simple stack machine.  Values in the stack
    have a type and a size.  Operations on the stack values are
    also typed.  Type mismatches may cause bad code to be generated
    or an error to be signaled.  Explicit type conversions must be used.

    Integer values on the stack, regardless of how they are loaded,
    are sign-extended to at least 32-bit values.  Similarly, word values
    on the stack are always zero-extended to at least 32-bit values.
    
    The expression stack must be empty at each label, jump, or call.
    The stack must contain exactly one value prior to a conditional
    or indexed jump.

    All addresses are byte addresses.  There is no boolean type;  boolean
    operators yield [0..1].

    Operations on word values are performed MOD the word size and are
    not checked for overflow.  Operations on integer values may or may not
    cause checked runtime errors depending on the particular code generator.

    The operators are declared below with a definition in terms of
    what they do to the execution stack.  For example,  ceiling(Reel, Int32)
    returns the ceiling, a 32-bit integer, of the top value on the stack,
    a single-precision real:  s0.Int32 := CEILING (s0.Reel).

    Unless otherwise indicated, operators have the same meaning as in
    the Modula-3 report.
*)

(*-------------------------------------------------------------- literals ---*)

load_nil     ();                         (*push; s0.A := NIL*)
load_integer (t: IType;  READONLY i: Target.Int);   (*push; s0.t := i *)
load_float   (t: RType;  READONLY f: Target.Float); (*push; s0.t := f *)

(*------------------------------------------------------------ arithmetic ---*)

(* when any of these operators is passed t=Type.Word32 or Type.Word64,
   the operator does the unsigned comparison or arithmetic, but the operands
   and the result are of type Integer *)
   
compare  (t: ZType;  u: IType;  op: CompareOp);   (* s1.u := (s1.t op s0.t); pop *)
add      (t: AType);   (* s1.t := s1.t + s0.t; pop *)
subtract (t: AType);   (* s1.t := s1.t - s0.t; pop *)
multiply (t: AType);   (* s1.t := s1.t * s0.t; pop *)
divide   (t: RType);   (* s1.t := s1.t / s0.t; pop *)
negate   (t: AType);   (* s0.t := - s0.t *)
abs      (t: AType);   (* s0.t := ABS (s0.t) (noop on Words) *)
max      (t: ZType);   (* s1.t := MAX (s1.t, s0.t); pop *)
min      (t: ZType);   (* s1.t := MIN (s1.t, s0.t); pop *)
cvt_int  (t: RType;  u: IType;  op: ConvertOp);     (* s0.u := op (s0.t) *)
cvt_float(t: AType;  u: RType);     (* s0.u := FLOAT (s0.t, u) *)
div      (t: IType;  a, b: Sign);   (* s1.t := s1.t DIV s0.t;pop*)
mod      (t: IType;  a, b: Sign);   (* s1.t := s1.t MOD s0.t;pop*)

(* In div and mod, "a" is the sign of s1 and "b" is the sign of s0. *)

(*------------------------------------------------------------------ sets ---*)

(* Sets are represented on the stack as addresses. *)

set_union (s: ByteSize);          (* s2.B := s1.B + s0.B; pop(3) *)
set_difference (s: ByteSize);     (* s2.B := s1.B - s0.B; pop(3) *)
set_intersection (s: ByteSize);   (* s2.B := s1.B * s0.B; pop(3) *)
set_sym_difference (s: ByteSize); (* s2.B := s1.B / s0.B; pop(3) *)
set_member (s: ByteSize;  t: IType);  (* s1.t := (s0.t IN s1.B); pop *)
set_compare (s: ByteSize;  op: CompareOp;  t: IType);  (* s1.t := (s1.B op s0.B); pop *)
set_range (s: ByteSize;  t: IType);         (* s2.A[s1.t..s0.t] := 1; pop(3) *)
set_singleton (s: ByteSize;  t: IType);     (* s1.A [s0.t] := 1; pop(2) *)

(*------------------------------------------------- Word.T bit operations ---*)

not (t: IType);  (* s0.t := Word.Not (s0.t) *)
and (t: IType);  (* s1.t := Word.And (s1.t, s0.t); pop *)
or  (t: IType);  (* s1.t := Word.Or  (s1.t, s0.t); pop *)
xor (t: IType);  (* s1.t := Word.Xor (s1.t, s0.t); pop *)

shift        (t: IType);  (* s1.t := Word.Shift  (s1.t, s0.t); pop *)
shift_left   (t: IType);  (* s1.t := Word.Shift  (s1.t, s0.t); pop *)
shift_right  (t: IType);  (* s1.t := Word.Shift  (s1.t, -s0.t); pop *)
rotate       (t: IType);  (* s1.t := Word.Rotate (s1.t, s0.t); pop *)
rotate_left  (t: IType);  (* s1.t := Word.Rotate (s1.t, s0.t); pop *)
rotate_right (t: IType);  (* s1.t := Word.Rotate (s1.t, -s0.t); pop *)

widen (sign: BOOLEAN);
(* s0.I64 := s0.I32;  IF sign THEN SignExtend s0;  *)

chop ();
(* s0.I32 := Word.And (s0.I64, 16_ffffffff);  *)

extract (t: IType;  sign: BOOLEAN);
(* s2.t := Word.Extract(s2.t, s1.t, s0.t);
   IF sign THEN SignExtend s2; pop(2) *)

extract_n (t: IType;  sign: BOOLEAN;  n: INTEGER);
(* s1.t := Word.Extract(s1.t, s0.t, n);
   IF sign THEN SignExtend s1; pop(1) *)

extract_mn (t: IType;  sign: BOOLEAN;  m, n: INTEGER);
(* s0.t := Word.Extract(s0.t, m, n);
   IF sign THEN SignExtend s0 *)

insert (t: IType);
(* s3.t := Word.Insert (s3.t, s2.t, s1.t, s0.t); pop(3) *)

insert_n (t: IType;  n: INTEGER);
(* s2.t := Word.Insert (s2.t, s1.t, s0.t, n); pop(2) *)

insert_mn (t: IType;  m, n: INTEGER);
(* s1.t := Word.Insert (s1.t, s0.t, m, n); pop(1) *)

(*------------------------------------------------ misc. stack/memory ops ---*)

swap (a, b: Type);
(* tmp := s1.a; s1.b := s0.b; s0.a := tmp *)

pop (t: Type);
(* pop(1) discard s0, not its side effects *)

copy_n (u: IType;  t: MType;  overlap: BOOLEAN);
(* copy s0.u units with 't's size and alignment from s1.A to s2.A; pop(3).
   'overlap' is true if the source and destination may partially overlap
   (ie. you need memmove, not just memcpy). *)

copy (n: INTEGER;  t: MType;  overlap: BOOLEAN);
(* copy 'n' units with 't's size and alignment from s0.A to s1.A; pop(2).
   'overlap' is true if the source and destination may partially overlap
   (ie. you need memmove, not just memcpy). *)

zero_n (u: IType;  t: MType);
(* zero s0.u units with 't's size and alignment starting at s1.A; pop(2) *)

zero (n: INTEGER;  t: MType);
(* zero 'n' units with 't's size and alignment starting at s0.A; pop(1) *)

(*----------------------------------------------------------- conversions ---*)

loophole (from, two: ZType);
(* s0.two := LOOPHOLE(s0.from, two) *)

(*------------------------------------------------ traps & runtime checks ---*)

abort (code: RuntimeError);
(* generate a checked runtime error for "code" *)

check_nil (code: RuntimeError);
(* IF (s0.A = NIL) THEN abort(code) *)

check_lo (t: IType;  READONLY i: Target.Int;  code: RuntimeError);
(* IF (s0.t < i) THEN abort(code) *)

check_hi (t: IType;  READONLY i: Target.Int;  code: RuntimeError);
(* IF (i < s0.t) THEN abort(code) *)

check_range (t: IType;  READONLY a, b: Target.Int;  code: RuntimeError);
(* IF (s0.t < a) OR (b < s0.t) THEN abort(code) *)

check_index (t: IType;  code: RuntimeError);
(* IF NOT (0 <= s1.t < s0.t) THEN abort(code) END; pop
   s0.t is guaranteed to be positive so the unsigned
   check (s0.W < s1.W) is sufficient. *)

check_eq (t: IType;  code: RuntimeError);
(* IF (s0.t # s1.t) THEN abort(code);  Pop (2) *)

(*---------------------------------------------------- address arithmetic ---*)

add_offset (i: INTEGER);
(* s0.A := s0.A + i bytes *)

index_address (t: IType;  size: INTEGER);
(* s1.A := s1.A + s0.t * size; pop  -- where 'size' is in bytes *)

(*------------------------------------------------------- procedure calls ---*)

(* To generate a direct procedure call:
    
      cg.start_call_direct (proc, level, t);
    
      for each actual parameter i
          <generate value for parameter i>
          cg.pop_param ();  -or-  cg.pop_struct();
        
      cg.call_direct (proc, t);

   or to generate an indirect call:

      cg.start_call_indirect (t);
    
      for each actual parameter i
          <generate value for parameter i>
          cg.pop_param ();  -or-  cg.pop_struct();

      If the target is a nested procedure,
          <evaluate the static link to be used>
          cg.pop_static_link ();

      <evaluate the address of the procedure to call>
      cg.call_indirect (t);
*)

start_call_direct (p: Proc;  lev: INTEGER;  t: Type);
(* begin a procedure call to procedure 'p' at static level 'lev' that
   will return a value of type 't'. *)

call_direct (p: Proc;  t: Type);
(* call the procedure 'p'.  It returns a value of type t. *)

start_call_indirect (t: Type;  cc: CallingConvention);
(* begin an indirect procedure call that will return a value of type 't'. *)

call_indirect (t: Type;  cc: CallingConvention);
(* call the procedure whose address is in s0.A and pop s0.  The
   procedure returns a value of type t. *)

pop_param (t: MType);
(* pop s0.t and make it the "next" parameter in the current call. *)

pop_struct (s: ByteSize;  a: Alignment);
(* pop s0.A, it's a pointer to a structure occupying 's' bytes that's
  'a' byte aligned; pass the structure by value as the "next" parameter
  in the current call. *)

pop_static_link ();
(* pop s0.A for the current indirect procedure call's static link  *)

(*------------------------------------------- procedure and closure types ---*)

load_procedure (p: Proc);
(* push; s0.A := ADDR (p's body) *)

load_static_link (p: Proc);
(* push; s0.A := (static link needed to call p, NIL for top-level procs) *)

(*----------------------------------------------------------------- misc. ---*)

comment (a, b, c, d: TEXT := NIL);
(* annotate the output with a&b&c&d as a comment.  Note that any of a,b,c or d
   may be NIL. *)

END; (* TYPE Public *)

END M3CG_Ops.



