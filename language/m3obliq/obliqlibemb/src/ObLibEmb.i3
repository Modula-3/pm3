(*                            -*- Mode: Modula-3 -*- 
 * 
 * For information about this program, contact Blair MacIntyre            
 * (bm@cs.columbia.edu) or Steven Feiner (feiner@cs.columbia.edu)         
 * at the Computer Science Dept., Columbia University,                    
 * 1214 Amsterdam Ave. Mailstop 0401, New York, NY, 10027.                
 *                                                                        
 * Copyright (C) 1995, 1996 by The Trustees of Columbia University in the 
 * City of New York.  Blair MacIntyre, Computer Science Department.       
 * 
 * Author          : Blair MacIntyre
 * Created On      : Thu Aug 10 09:30:55 1995
 * Last Modified By: Blair MacIntyre
 * Last Modified On: Wed Mar 12 12:16:19 1997
 * Update Count    : 5
 * 
 * $Source$
 * $Date$
 * $Author$
 * $Revision$
 * 
 * $Log$
 * Revision 1.1  2003/04/08 21:57:56  hosking
 * Merge of PM3 with Persistent M3 and CM3 release 5.1.8
 *
 * Revision 1.1.3.1  2003/01/27 00:35:57  hosking
 * Import of CM3 5.1.8
 *
 * Revision 1.1.1.1  2001/01/24 21:52:38  wagner
 * import of Critical Mass sources of release 5.1
 *
 * Revision 1.2  1997/03/12 21:34:57  bm
 * Moved sharedobj from coterie
 *
 * 
 * HISTORY
 *)

INTERFACE ObLibEmb;

IMPORT ObLoader;

PROCEDURE PackageSetup() : ObLoader.T; 

(* To be called at least once before any other use of the obliq
  embedding package.  Any package that builds on this library should use
  this loader to initialize their new loaders so that the environment is
  passed on. *)

END ObLibEmb. 
