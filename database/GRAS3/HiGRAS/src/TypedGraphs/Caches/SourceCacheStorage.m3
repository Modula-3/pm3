MODULE SourceCacheStorage;

(***************************************************************************)
(** Created by:  Roland Baumann						   *)

(** $Author$
    $Revision$
    $Date$
    $Log$
    Revision 1.1  2003/03/27 15:25:36  hosking
    Initial revision

    Revision 1.2  1997/07/21 10:49:52  roland
    Adapted to new set implementation (free memory lists and deleted
    SetExceptions)

    Revision 1.1  1997/07/07 15:43:42  roland
    Added caches for relations in a Scheme.

*)
(***************************************************************************)

IMPORT ChgMgmtGraph, PersistentGraph, NodeSet, NodeCard, Access,
       ErrorSupport, Node;

REVEAL
  T = Public BRANDED Brand OBJECT
        graph: ChgMgmtGraph.T;
      OVERRIDES
        init  := Init;
        read  := Read;
        write := Write;
      END;

PROCEDURE Init (st: T; graph: ChgMgmtGraph.T): T =
  BEGIN
    st.graph := graph;
    RETURN st;
  END Init;


PROCEDURE Read (         st   : T;
                READONLY key  : NodeCard.T;
                VAR      val  : NodeSet.T;
                VAR      found: BOOLEAN     ) RAISES {Error} =
  BEGIN
    TRY
      val := st.graph.getSources(key.node, key.num);
      found := TRUE;
    EXCEPT
    | Access.Locked =>
        RAISE Error(ErrorSupport.Create(
                      "SourceCacheStorage.Read", "Access.Locked"));
    | PersistentGraph.NotOwner =>
        RAISE
          Error(ErrorSupport.Create(
                  "SourceCacheStorage.Read", "PeristentGraph.NotOwner"));
    | PersistentGraph.InternalError (info) =>
        RAISE Error(ErrorSupport.Propagate(
                      "SourceCacheStorage.Read",
                      "PersistentGraph.InternalError", info));
    | PersistentGraph.NodeNotFound => found := FALSE;
    END;
  END Read;

PROCEDURE Write (st: T; READONLY key: NodeCard.T; val: NodeSet.T)
  RAISES {Error} =
  VAR
    ok  : BOOLEAN;
    node: Node.T;
  BEGIN
    TRY
      val.loop();
      node := val.get(ok);
      WHILE ok DO
        st.graph.createEdge(node, key.node, key.num);
        node := val.get(ok);
      END;
    EXCEPT
    | PersistentGraph.NotOwner =>
        RAISE Error(ErrorSupport.Create("SourceCacheStorage.Write",
                                        "PersistentGraph.NotOwner"));
    | ChgMgmtGraph.InternalError (info) =>
        RAISE
          Error(ErrorSupport.Propagate("SourceCacheStorage.Write",
                                       "ChgMgmtGraph.InternalError", info));
    | PersistentGraph.NodeNotFound =>
        RAISE Error(ErrorSupport.Create("SourceCacheStorage.Write",
                                        "PersistentGraph.NodeNotFound"));
    | ChgMgmtGraph.LogError (info) =>
        RAISE Error(ErrorSupport.Propagate("SourceCacheStorage.Write",
                                           "ChgMgmtGraph.LogError", info));
    | Access.Locked =>
        RAISE Error(ErrorSupport.Create(
                      "SourceCacheStorage.Write", "Access.Locked"));
    END;
  END Write;


BEGIN
END SourceCacheStorage.
