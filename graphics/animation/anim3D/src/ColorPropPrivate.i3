(* Copyright (C) 1994, Digital Equipment Corporation                         *)
(* Digital Internal Use Only                                                 *)
(* All rights reserved.                                                      *)
(*                                                                           *)
(* Last modified on Mon Jan 30 22:17:54 PST 1995 by najork                   *)
(*       Created on Sun May 22 10:44:46 PDT 1994 by najork                   *)


INTERFACE ColorPropPrivate;

IMPORT GraphicsBase, Prop, PropPrivate;

FROM ColorProp IMPORT Base, Name, PublicName, Val, PublicVal, Beh, PublicBeh;

REVEAL 
  Name <: PrivateName;

TYPE 
  PrivateName = PublicName OBJECT
  METHODS
    init (default: Base) : Name;
    getState (base : GraphicsBase.T) : Base;
  END;

REVEAL 
  Val <: PrivateVal;

TYPE 
  PrivateVal = PublicVal OBJECT
    val : Base;     (* The cache is updated by calling "adjust". *)
  END;

REVEAL 
  Beh <: PrivateBeh;

TYPE 
  PrivateBeh = PublicBeh OBJECT
  METHODS 
    value (time : LONGREAL) : Base RAISES {Prop.BadMethod};
  END;

TYPE 
  Stack <: PublicStack;
  PublicStack = PropPrivate.Stack OBJECT
    top : Base;
  METHODS 
    push (val : Base);
    pop () : Base;
  END;


END ColorPropPrivate.
