UNSAFE MODULE Transaction EXPORTS Transaction, InternalTransaction;

IMPORT RTIO, RTHeapDB, RTDB, VirtualResource, Atom, AtomList, Txn,
       DB, BaseTransaction, Thread, ThreadF;
FROM DB IMPORT resource;

REVEAL
  T = Internal BRANDED "Transaction.T" OBJECT
    open := FALSE;
  OVERRIDES
    init := Init;

    begin := Begin;
    commit := Commit;
    chain := Chain;
    abort := Abort;
    checkpoint := Checkpoint;
    isOpen := IsOpen;
    lock := Lock;
  END;

PROCEDURE Init(self: T): BaseTransaction.T =
  BEGIN
    EVAL BaseTransaction.T.init(self);
    RETURN self;
  END Init;

EXCEPTION FatalError; <*FATAL FatalError*>
PROCEDURE fatalAtoms (t: AtomList.T) =
  BEGIN
    WHILE t # NIL DO
      RTIO.PutText(Atom.ToText(t.head)); RTIO.PutChar('\n');
      t := t.tail;
    END;
    RTIO.Flush();
    RAISE FatalError;
  END fatalAtoms;

PROCEDURE Begin(self: T)
  RAISES { InProgress, Thread.Aborted } =
  BEGIN
    IF resource.getTransactionLevel() # Txn.EnvelopeLevel THEN
      IF ThreadF.myTxn = NIL THEN RAISE InProgress END;
      RTHeapDB.Flush(release:= FALSE);
    END;
    LOCK self DO
      EVAL self.init();
      IF self.open THEN RAISE InProgress END;
      TRY
        resource.beginTransaction();
      EXCEPT
      | VirtualResource.FatalError(t) => fatalAtoms(t);
      END;
      ThreadF.TxnBegin(self);
      self.open := TRUE;
    END
  END Begin;

PROCEDURE Commit(self: T)
  RAISES { NotInProgress, Thread.Aborted } =
  VAR outer: Txn.Level;
  BEGIN
    RTHeapDB.Flush();
    LOCK self DO
      IF NOT self.open THEN RAISE NotInProgress; END;
      TRY
        resource.commitTransaction();
        outer := resource.getTransactionLevel();
      EXCEPT
      | VirtualResource.NotInTransaction => RAISE NotInProgress;
      | VirtualResource.FatalError(t) => fatalAtoms(t);
      END;
      ThreadF.TxnCommit();
      self.open := FALSE;
    END;
  END Commit;

PROCEDURE Chain(self: T)
  RAISES { NotInProgress, Thread.Aborted } =
  BEGIN
    RTHeapDB.Flush(release := FALSE);
    LOCK self DO
      IF NOT self.open THEN RAISE NotInProgress; END;
      TRY
        resource.chainTransaction();
      EXCEPT
      | VirtualResource.NotInTransaction => RAISE NotInProgress;
      | VirtualResource.FatalError(t) => fatalAtoms(t);
      END;
    END
  END Chain; 

PROCEDURE Abort(self: T) RAISES { NotInProgress } =
  VAR outer: Txn.Level;
  BEGIN
    LOCK self DO
      IF NOT self.open THEN RAISE NotInProgress; END;
      RTHeapDB.Abort();
      TRY
        resource.abortTransaction();
        outer := resource.getTransactionLevel();
      EXCEPT
      | VirtualResource.NotInTransaction => RAISE NotInProgress;
      | VirtualResource.FatalError(t) => fatalAtoms(t);
      END;
      ThreadF.TxnAbort();
      self.open := FALSE;
    END;
  END Abort;

PROCEDURE Checkpoint(self: T)
  RAISES { NotInProgress, Thread.Aborted } =
  BEGIN
    RTHeapDB.Flush(release := FALSE);
    LOCK self DO
      IF NOT self.open THEN RAISE NotInProgress; END;
    END;
  END Checkpoint;

PROCEDURE IsOpen(self: T): BOOLEAN =
  BEGIN
    LOCK self DO
      RETURN self.open;
    END;
  END IsOpen;

PROCEDURE Lock(<*UNUSED*> self: T; object: REFANY; mode: LockMode)
  RAISES { Thread.Aborted } =
  VAR p: RTDB.Page;
  BEGIN
    p := RTHeapDB.RefPageMap(object);
    IF p # NIL THEN
      CASE mode OF
      | LockMode.READ  => p.readAccess(NIL);
      | LockMode.WRITE => p.writeAccess(NIL);
      END
    END
  END Lock;

BEGIN
END Transaction.
