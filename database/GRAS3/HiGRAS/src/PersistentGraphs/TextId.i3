INTERFACE TextId;

(***************************************************************************)
(** Created by:  Roland Baumann						   *)

(** $Author$
    $Revision$
    $Date$
    $Log$
    Revision 1.1  2003/03/27 15:25:32  hosking
    Initial revision

    Revision 1.2  1997/07/21 10:40:59  roland
    Brand needed for new set implementation.

    Revision 1.1  1997/03/26 11:39:50  roland
    Subsystem PersistentGraph adapted to handle graph boundary crossing
    edges. This has consequences on the architecture of the subsystem as
    well as on the graph model and interface.

    Graphs are organized in pools. Every graph has a number in the
    pool. Pools are the units of transaction management. Two graphs might
    be related by one external relation storage storing the edges between
    nodes of them. Nodes are identified by pairs (graph, entity), where
    graph is the number of the graph in the pool and entity the node
    number within the graph. Graphs and external relation storages are
    administered by the pool in a separate graph.

    Revision 1.1  1996/12/20 17:33:02  roland
    An abstract data object for persistent collections of names.

    Revision 1.1  1996/09/23 08:34:26  roland
    Persistent Deltas are now stored as part of the checkpoint
    tree. Backstep and forstep work.
    Names will be used to hold information for ChgMgmtGraphSystem.

*)
(***************************************************************************)

CONST Brand = "TextId";

TYPE T = RECORD
           text: TEXT;
           id: CARDINAL;
         END;

PROCEDURE Compare(a, b: T) : [-1..1];
     
END TextId.
