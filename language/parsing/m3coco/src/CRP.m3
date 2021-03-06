MODULE CRP EXPORTS CR ;

(* Parser generated by m3coco *)

IMPORT Rd, Thread ;



(*---------------------- semantic declarations -----------------------*)

IMPORT CRT, CRA ;
IMPORT Text, ASCII ;

CONST
  ident  = 0 ;
  string = 1 ; (* symbol kind *)

PROCEDURE FixString(p : Parser) : TEXT =
VAR
  double := FALSE ;
  spaces := FALSE ;
  name   := p.name() ;
  len    := Text.Length(name) ;
  c      := NEW(REF ARRAY OF CHAR, len) ;
BEGIN
  Text.SetChars(c^, name) ;
  IF (CRT.ignoreCase) THEN (* force uppercase *)
    FOR i := 1 TO len - 2 DO
      c[i] := ASCII.Upper[c[i]]
    END ;
  END ;
  FOR i := 1 TO len - 2 DO (* search for interior " or spaces *)
    IF (c[i] = '"') THEN
      double := TRUE
    END ;
    IF (c[i] = ' ') THEN
      spaces := TRUE
    END
  END ;
  IF (NOT double) THEN (* force delimiters to be " quotes *)
    c[0] := '"' ;
    c[len - 1] := '"'
  END ;
  IF (spaces) THEN
    p.error("spaces not allowed within tokens")
  END ;
  RETURN Text.FromChars(c^)
END FixString;

PROCEDURE MatchLiteral(p : Parser ; sp : INTEGER) =
(* store string either as token or as literal *)
VAR
  sn, sn1   :  CRT.SymbolNode ;
  matchedSp : INTEGER ;
BEGIN
  CRT.GetSym(sp, sn) ;
  CRA.MatchDFA(p, sn.name, sp, matchedSp) ;
  IF (matchedSp # CRT.noSym) THEN
    CRT.GetSym(matchedSp, sn1) ;
    sn1.struct := ORD(CRT.TokenKind.classLitToken) ;
    CRT.PutSym(matchedSp, sn1) ;
    sn.struct := ORD(CRT.TokenKind.litToken) ;
  ELSE
    sn.struct := ORD(CRT.TokenKind.classToken) ;
  END ;
  CRT.PutSym(sp, sn)
END MatchLiteral ;

PROCEDURE SetCtx(gp : INTEGER) =
(* set transition code to CRT.contextTrans *)
VAR
  gn : CRT.GraphNode ;
BEGIN
  WHILE (gp > 0) DO
    CRT.GetNode(gp, gn) ;
    IF ((gn.typ = CRT.NodeType.char) OR (gn.typ = CRT.NodeType.class)) THEN
      gn.p2 := CRT.contextTrans ;
      CRT.PutNode(gp, gn)
    ELSIF ((gn.typ = CRT.NodeType.opt) OR (gn.typ = CRT.NodeType.iter)) THEN
      SetCtx(gn.p1)
    ELSIF (gn.typ = CRT.NodeType.alt) THEN
      SetCtx(gn.p1) ;
      SetCtx(gn.p2)
    END ;
    gp := gn.next
  END
END SetCtx ;

PROCEDURE SetOption (s: TEXT) =
VAR
  c : CHAR ;
BEGIN
  FOR i := 0 TO (Text.Length(s) - 1) DO
    c := ASCII.Upper[Text.GetChar(s, i)] ;
    IF (c IN ASCII.Uppers) THEN
      CRT.ddt[c] := TRUE
    END
  END
END SetOption ;

CONST 
  minErrDist = 2 ;  (* minimal distance (good tokens) between two errors *)

TYPE
  SymSetRange = [0 .. 14] ;

CONST
  SymSet = ARRAY SymSetRange OF SymbolSet {
      SymbolSet{Symbol.Eof, Symbol.ident, Symbol.string, 
                        Symbol.sPRODUCTIONS, Symbol.Equal, Symbol.sCHARACTERS, 
                        Symbol.sTOKENS, Symbol.sNAMES, Symbol.sPRAGMAS, 
                        Symbol.sCOMMENTS, Symbol.sIGNORE, Symbol.sLbrDot},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.Dot, Symbol.sANY, 
                        Symbol.Lbr, Symbol.Rbr, Symbol.Bar, Symbol.sWEAK, 
                        Symbol.Lsqu, Symbol.Rsqu, Symbol.Lcurl, Symbol.Rcurl, 
                        Symbol.sSYNC, Symbol.sLbrDot},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.sANY, Symbol.Lbr, 
                        Symbol.sWEAK, Symbol.Lsqu, Symbol.Lcurl, Symbol.sSYNC, 
                        Symbol.sLbrDot},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.Lbr, Symbol.Lsqu, 
                        Symbol.Lcurl},
      SymbolSet{Symbol.sPRODUCTIONS, Symbol.Dot, Symbol.sCHARACTERS, 
                        Symbol.sTOKENS, Symbol.sNAMES, Symbol.sPRAGMAS, 
                        Symbol.sCOMMENTS, Symbol.sTO, Symbol.sNESTED, 
                        Symbol.sIGNORE, Symbol.Rbr, Symbol.Rsqu, Symbol.Rcurl},
      SymbolSet{Symbol.Eof, Symbol.ident, Symbol.string, 
                        Symbol.sPRODUCTIONS, Symbol.Equal, Symbol.sCHARACTERS, 
                        Symbol.sTOKENS, Symbol.sNAMES, Symbol.sPRAGMAS, 
                        Symbol.sCOMMENTS, Symbol.sIGNORE, Symbol.sLbrDot},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.sPRODUCTIONS, 
                        Symbol.sCHARACTERS, Symbol.sTOKENS, Symbol.sNAMES, 
                        Symbol.sPRAGMAS, Symbol.sCOMMENTS, Symbol.sIGNORE, 
                        Symbol.sLbrDot},
      SymbolSet{Symbol.Dot, Symbol.Rbr, Symbol.Rsqu, Symbol.Rcurl},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.number, 
                        Symbol.sCOMPILER, Symbol.sPRODUCTIONS, Symbol.Equal, 
                        Symbol.Dot, Symbol.sEND, Symbol.sCHARACTERS, 
                        Symbol.sTOKENS, Symbol.sNAMES, Symbol.sPRAGMAS, 
                        Symbol.sCOMMENTS, Symbol.sFROM, Symbol.sTO, 
                        Symbol.sNESTED, Symbol.sIGNORE, Symbol.sCASE, 
                        Symbol.Plus, Symbol.Dash, Symbol.sDotDot, Symbol.sANY, 
                        Symbol.sCHR, Symbol.Lbr, Symbol.Rbr, Symbol.Bar, 
                        Symbol.sWEAK, Symbol.Lsqu, Symbol.Rsqu, Symbol.Lcurl, 
                        Symbol.Rcurl, Symbol.sSYNC, Symbol.sCONTEXT, Symbol.Less, 
                        Symbol.Gtr, Symbol.sLbrDot, Symbol.Undef},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.number, 
                        Symbol.sCOMPILER, Symbol.sPRODUCTIONS, Symbol.Equal, 
                        Symbol.Dot, Symbol.sEND, Symbol.sCHARACTERS, 
                        Symbol.sTOKENS, Symbol.sNAMES, Symbol.sPRAGMAS, 
                        Symbol.sCOMMENTS, Symbol.sFROM, Symbol.sTO, 
                        Symbol.sNESTED, Symbol.sIGNORE, Symbol.sCASE, 
                        Symbol.Plus, Symbol.Dash, Symbol.sDotDot, Symbol.sANY, 
                        Symbol.sCHR, Symbol.Lbr, Symbol.Rbr, Symbol.Bar, 
                        Symbol.sWEAK, Symbol.Lsqu, Symbol.Rsqu, Symbol.Lcurl, 
                        Symbol.Rcurl, Symbol.sSYNC, Symbol.sCONTEXT, Symbol.Less, 
                        Symbol.sLbrDot, Symbol.sDotRbr, Symbol.Undef},
      SymbolSet{Symbol.sPRODUCTIONS, Symbol.sCHARACTERS, Symbol.sTOKENS, 
                        Symbol.sNAMES, Symbol.sPRAGMAS, Symbol.sCOMMENTS, 
                        Symbol.sIGNORE},
      SymbolSet{Symbol.ident, Symbol.string, Symbol.number, 
                        Symbol.sCOMPILER, Symbol.Equal, Symbol.Dot, Symbol.sEND, 
                        Symbol.sFROM, Symbol.sTO, Symbol.sNESTED, Symbol.sCASE, 
                        Symbol.Plus, Symbol.Dash, Symbol.sDotDot, Symbol.sANY, 
                        Symbol.sCHR, Symbol.Lbr, Symbol.Rbr, Symbol.Bar, 
                        Symbol.sWEAK, Symbol.Lsqu, Symbol.Rsqu, Symbol.Lcurl, 
                        Symbol.Rcurl, Symbol.sSYNC, Symbol.sCONTEXT, Symbol.Less, 
                        Symbol.Gtr, Symbol.sLbrDot, Symbol.sDotRbr, Symbol.Undef},
      SymbolSet{Symbol.sCHARACTERS, Symbol.sTOKENS, Symbol.sNAMES, 
                        Symbol.sPRAGMAS, Symbol.sCOMMENTS, Symbol.sIGNORE},
      SymbolSet{Symbol.Eof, Symbol.ident, Symbol.string, 
                        Symbol.sPRODUCTIONS, Symbol.Equal, Symbol.Dot, 
                        Symbol.sCHARACTERS, Symbol.sTOKENS, Symbol.sNAMES, 
                        Symbol.sPRAGMAS, Symbol.sCOMMENTS, Symbol.sIGNORE, 
                        Symbol.sANY, Symbol.Lbr, Symbol.Bar, Symbol.sWEAK, 
                        Symbol.Lsqu, Symbol.Lcurl, Symbol.sSYNC, Symbol.sLbrDot},
      SymbolSet{Symbol.Eof, Symbol.ident, Symbol.string, 
                        Symbol.sPRODUCTIONS, Symbol.Equal, Symbol.sEND, 
                        Symbol.sCHARACTERS, Symbol.sTOKENS, Symbol.sNAMES, 
                        Symbol.sPRAGMAS, Symbol.sCOMMENTS, Symbol.sIGNORE, 
                        Symbol.sLbrDot}
  } ;

  PragmaSet = SymbolSet { Symbol.Options } ;

REVEAL
  Parser = PublicP BRANDED OBJECT
             s       : Scanner ;
             err     : ErrHandler ;
             cur     : ScanSymbol ; (* current symbol *)
             next    : ScanSymbol ; (* next [lookahead] symbol *)
             errDist : CARDINAL     (* number of tokens since last err *)
           OVERRIDES
             init   := Init ;
             error  := SemError ;
             string := GetString ;
             name   := GetName ;
             offset := GetOffset ;
             line   := GetLine ;
             column := GetColumn ;
             length := GetLength ;
             parse  := Parse
           END ;

PROCEDURE SemError(p : Parser ; msg : TEXT) =
BEGIN
  IF (p.errDist >= minErrDist) THEN
    p.err.error(p.cur.line, p.cur.column, msg)
  END ;
  p.errDist := 0
END SemError ;

PROCEDURE GetString(p : Parser) : TEXT =
BEGIN
  RETURN p.cur.string
END GetString ;

PROCEDURE GetName(p : Parser) : TEXT =
BEGIN
  RETURN p.cur.name
END GetName ;

PROCEDURE GetOffset(p : Parser) : CARDINAL =
BEGIN
  RETURN p.cur.offset
END GetOffset ;

PROCEDURE GetLine(p : Parser) : CARDINAL =
BEGIN
  RETURN p.cur.line
END GetLine ;

PROCEDURE GetColumn(p : Parser) : CARDINAL =
BEGIN
  RETURN p.cur.column
END GetColumn ;

PROCEDURE GetLength(p : Parser) : CARDINAL =
BEGIN
  RETURN p.cur.length
END GetLength ;

PROCEDURE SynError(p : Parser ; msg : TEXT) =
BEGIN
  IF (p.errDist >= minErrDist) THEN
    p.err.error(p.next.line, p.next.column, msg)
  END ;
  p.errDist := 0
END SynError ;

PROCEDURE Get(p : Parser) =
BEGIN
  p.cur := p.next ;
  REPEAT
    p.s.get(p.next) ;
    IF (p.next.sym IN PragmaSet) THEN
      VAR tmp := p.cur ;
      BEGIN
        p.cur := p.next ;
        CASE p.next.sym OF
          Symbol.Options =>
              SetOption(p.name()) ;ELSE
        END ;
        p.cur := tmp
      END
    END
  UNTIL (NOT (p.next.sym IN PragmaSet)) ;
  INC(p.errDist)
END Get ;

PROCEDURE Expect(p : Parser ; sym : Symbol) =
BEGIN
  IF (p.next.sym = sym) THEN
    Get(p)
  ELSE
    SynError(p, "expected '" & SymbolName[sym] &
                  "', got '" & SymbolName[p.next.sym] & "'")
  END
END Expect ;

<*NOWARN*>PROCEDURE ExpectWeak(p : Parser ; sym : Symbol ; follow : SymSetRange) =
BEGIN
  IF (p.next.sym = sym) THEN
    Get(p)
  ELSE
    SynError(p, "expected '" & SymbolName[sym] &
                  "', got '" & SymbolName[p.next.sym] & "'") ;
    WHILE (NOT (p.next.sym IN SymSet[follow])) DO
      Get(p)
    END
  END
END ExpectWeak ;

<*NOWARN*>PROCEDURE WeakSeparator(p : Parser ; sym : Symbol ;
                        syFol, repFol : SymSetRange) : BOOLEAN =
VAR
  s : SymbolSet ;
BEGIN
  IF (p.next.sym = sym) THEN
    Get(p) ;
    RETURN TRUE
  ELSIF (p.next.sym IN SymSet[repFol]) THEN
    RETURN FALSE
  ELSE
    s := SymSet[0] + SymSet[syFol] + SymSet[repFol] ;
    SynError(p, "expected '" & SymbolName[sym] &
                  "', got '" & SymbolName[p.next.sym] & "'") ;
    WHILE (NOT (p.next.sym IN s)) DO
      Get(p)
    END ;
    RETURN (p.next.sym IN SymSet[syFol])
  END
END WeakSeparator ;

PROCEDURE ParseTokenFactor(p : Parser ; VAR gL, gR: INTEGER) =
  VAR
    kind, c: INTEGER;
    set:     CRT.Set;
    name:    TEXT;
BEGIN
  gL := 0 ;
  gR := 0 ;
  IF (p.next.sym = Symbol.ident) OR
     (p.next.sym = Symbol.string) THEN
    ParseSymbol(p, name, kind) ;
    IF (kind = ident) THEN
      c := CRT.ClassWithName(name) ;
      IF (c < 0) THEN
        p.error("undefined name '" & name & "'") ;
        set := CRT.Set{} ;
        c := CRT.NewClass(name, set)
      END ;
      gL := CRT.NewNode(CRT.NodeType.class, c, 0) ;
      gR := gL
    ELSE (*string*)
      CRT.StrToGraph(name, gL, gR)
    END ;
  ELSIF (p.next.sym = Symbol.Lbr) THEN
    Get(p) ;
    ParseTokenExpr(p, gL, gR) ;
    Expect(p, Symbol.Rbr) ;
  ELSIF (p.next.sym = Symbol.Lsqu) THEN
    Get(p) ;
    ParseTokenExpr(p, gL, gR) ;
    Expect(p, Symbol.Rsqu) ;
    CRT.MakeOption(gL, gR) ;
  ELSIF (p.next.sym = Symbol.Lcurl) THEN
    Get(p) ;
    ParseTokenExpr(p, gL, gR) ;
    Expect(p, Symbol.Rcurl) ;
    CRT.MakeIteration(gL, gR) ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in TokenFactor") ;
  END ;
END ParseTokenFactor ;

PROCEDURE ParseTokenTerm(p : Parser ; VAR gL, gR: INTEGER) =
  VAR gL2, gR2: INTEGER;
BEGIN
  ParseTokenFactor(p, gL, gR) ;
  WHILE (p.next.sym = Symbol.ident) OR
        (p.next.sym = Symbol.string) OR
        (p.next.sym = Symbol.Lbr) OR
        (p.next.sym = Symbol.Lsqu) OR
        (p.next.sym = Symbol.Lcurl) DO
    ParseTokenFactor(p, gL2, gR2) ;
    CRT.ConcatSeq(gL, gR, gL2, gR2) ;
  END ;
  IF (p.next.sym = Symbol.sCONTEXT) THEN
    Get(p) ;
    Expect(p, Symbol.Lbr) ;
    ParseTokenExpr(p, gL2, gR2) ;
    SetCtx(gL2) ;
    CRT.ConcatSeq(gL, gR, gL2, gR2) ;
    Expect(p, Symbol.Rbr) ;
  END ;
END ParseTokenTerm ;

PROCEDURE ParseFactor(p : Parser ; VAR gL, gR: INTEGER) =
  VAR
    sp, kind:    INTEGER;
    name:        TEXT;
    gn:          CRT.GraphNode;
    sn:          CRT.SymbolNode;
    set:         CRT.Set;
    undef, weak: BOOLEAN;
    pos:         CRT.Position;
BEGIN
  gL := 0 ;
  gR := 0 ;
  weak := FALSE ;
  CASE p.next.sym OF
    Symbol.ident, Symbol.string, Symbol.sWEAK =>
      IF (p.next.sym = Symbol.sWEAK) THEN
        Get(p) ;
        weak := TRUE ;
      END ;
      ParseSymbol(p, name, kind) ;
      sp := CRT.FindSym(name) ;
      undef := (sp = CRT.noSym) ;
      IF (undef) THEN
        IF (kind = ident) THEN  (*forward nt*)
          sp := CRT.NewSym(CRT.NodeType.nt, name, 0)
        ELSE  (*undefined string in production*)
          sp := CRT.NewSym(CRT.NodeType.t, name, p.line()) ;
          MatchLiteral(p, sp)
        END
      END ;
      CRT.GetSym(sp, sn) ;
      IF ((sn.typ # CRT.NodeType.t) AND (sn.typ # CRT.NodeType.nt)) THEN
        p.error("this symbol kind not allowed in production")
      END ;
      IF (weak) THEN
        IF (sn.typ = CRT.NodeType.t) THEN
          sn.typ := CRT.NodeType.wt
        ELSE
          p.error("only terminals may be weak")
        END
      END ;
      gL := CRT.NewNode(sn.typ, sp, p.line()) ;
      gR := gL ;
      IF (p.next.sym = Symbol.Less) THEN
        ParseAttribs(p, pos) ;
        CRT.GetNode(gL, gn) ;
        gn.pos := pos ;
        CRT.PutNode(gL, gn) ;
        CRT.GetSym(sp, sn) ;
        IF (undef) THEN
          sn.attrPos := pos ;
          CRT.PutSym(sp, sn)
        ELSIF (sn.attrPos.beg < 0) THEN
          p.error("symbol declared without attributes")
        END ;
        IF (kind # ident) THEN
          p.error("a literal must not have attributes")
        END ;
      ELSIF (p.next.sym IN SymSet[1]) THEN
        CRT.GetSym(sp, sn) ;
        IF (sn.attrPos.beg >= 0) THEN
          p.error("symbol declared with attributes")
        END ;
      ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Factor") ;
      END ;
  | Symbol.Lbr =>
      Get(p) ;
      ParseExpression(p, gL, gR) ;
      Expect(p, Symbol.Rbr) ;
  | Symbol.Lsqu =>
      Get(p) ;
      ParseExpression(p, gL, gR) ;
      Expect(p, Symbol.Rsqu) ;
      CRT.MakeOption(gL, gR) ;
  | Symbol.Lcurl =>
      Get(p) ;
      ParseExpression(p, gL, gR) ;
      Expect(p, Symbol.Rcurl) ;
      CRT.MakeIteration(gL, gR) ;
  | Symbol.sLbrDot =>
      ParseSemText(p, pos) ;
      gL := CRT.NewNode(CRT.NodeType.sem, 0, 0) ;
      gR := gL ;
      CRT.GetNode(gL, gn) ;
      gn.pos := pos ;
      CRT.PutNode(gL, gn) ;
  | Symbol.sANY =>
      Get(p) ;
      set := CRT.Set{0 .. CRT.maxTerminals} - CRT.Set{CRT.eofSy} ;
      gL := CRT.NewNode(CRT.NodeType.any, CRT.NewSet(set), 0) ;
      gR := gL ;
  | Symbol.sSYNC =>
      Get(p) ;
      gL := CRT.NewNode(CRT.NodeType.sync, 0, 0) ;
      gR := gL ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Factor") ;
  END ;
END ParseFactor ;

PROCEDURE ParseTerm(p : Parser ; VAR gL, gR: INTEGER) =
  VAR gL2, gR2: INTEGER;
BEGIN
  gL := 0 ;
  gR := 0 ;
  IF (p.next.sym IN SymSet[2]) THEN
    ParseFactor(p, gL, gR) ;
    WHILE (p.next.sym IN SymSet[2]) DO
      ParseFactor(p, gL2, gR2) ;
      CRT.ConcatSeq(gL, gR, gL2, gR2) ;
    END ;
  ELSIF (p.next.sym = Symbol.Dot) OR
        (p.next.sym = Symbol.Rbr) OR
        (p.next.sym = Symbol.Bar) OR
        (p.next.sym = Symbol.Rsqu) OR
        (p.next.sym = Symbol.Rcurl) THEN
    gL := CRT.NewNode(CRT.NodeType.eps, 0, 0) ;
    gR := gL ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Term") ;
  END ;
END ParseTerm ;

PROCEDURE ParseSymbol(p : Parser ; VAR name: TEXT; VAR kind: INTEGER) =
BEGIN
  IF (p.next.sym = Symbol.ident) THEN
    ParseIdent(p, name) ;
    kind := ident ;
  ELSIF (p.next.sym = Symbol.string) THEN
    Get(p) ;
    name := FixString(p) ;
    kind := string ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Symbol") ;
  END ;
END ParseSymbol ;

PROCEDURE ParseSingleChar(p : Parser ; VAR n: CARDINAL) =
  VAR i : CARDINAL ;
      s : TEXT ;
BEGIN
  Expect(p, Symbol.sCHR) ;
  Expect(p, Symbol.Lbr) ;
  Expect(p, Symbol.number) ;
  s := p.name() ;
  n := 0 ;
  i := 0 ;
  WHILE (i < Text.Length(s)) DO
    n := 10 * n + ORD(Text.GetChar(s, i)) - ORD('0') ;
    INC(i)
  END ;
  IF (n > 255) THEN
    p.error("unacceptable constant value") ;
    n := n MOD 256
  END ;
  IF (CRT.ignoreCase) THEN
    n := ORD(ASCII.Upper[VAL(n, CHAR)])
  END ;
  Expect(p, Symbol.Rbr) ;
END ParseSingleChar ;

PROCEDURE ParseSimSet(p : Parser ; VAR set: CRT.Set) =
  VAR i, n1, n2 : CARDINAL ;
      c         : INTEGER ;
      name      : TEXT ;
      s         : TEXT ;
      ch, ch0   : CHAR ;
BEGIN
  IF (p.next.sym = Symbol.ident) THEN
    ParseIdent(p, name) ;
    c := CRT.ClassWithName(name) ;
    IF (c < 0) THEN
      p.error("undefined name '" & name & "'") ;
      set := CRT.Set{}
    ELSE
      CRT.GetClass(c, set)
    END ;
  ELSIF (p.next.sym = Symbol.string) THEN
    Get(p) ;
    s   := p.name() ;
    set := CRT.Set{};
    i   := 1 ;
    ch0 := Text.GetChar(s, 0) ;
    ch  := Text.GetChar(s, i) ;
    WHILE (ch # ch0) DO
      IF (CRT.ignoreCase) THEN
        ch := ASCII.Upper[ch]
      END ;
      set := set + CRT.Set{ORD(ch)} ;
      INC(i) ;
      ch := Text.GetChar(s, i)
    END ;
  ELSIF (p.next.sym = Symbol.sCHR) THEN
    ParseSingleChar(p, n1) ;
    set := CRT.Set{n1} ;
    IF (p.next.sym = Symbol.sDotDot) THEN
      Get(p) ;
      ParseSingleChar(p, n2) ;
      set := set + CRT.Set{n1 .. n2} ;
    END ;
  ELSIF (p.next.sym = Symbol.sANY) THEN
    Get(p) ;
    set := CRT.Set{0 .. CRT.maxTerminals} ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in SimSet") ;
  END ;
END ParseSimSet ;

PROCEDURE ParseSet(p : Parser ; VAR set : CRT.Set) =
  VAR set2 : CRT.Set ;
BEGIN
  ParseSimSet(p, set) ;
  WHILE (p.next.sym = Symbol.Plus) OR
        (p.next.sym = Symbol.Dash) DO
    IF (p.next.sym = Symbol.Plus) THEN
      Get(p) ;
      ParseSimSet(p, set2) ;
      set := set + set2 ;
    ELSE
      Get(p) ;
      ParseSimSet(p, set2) ;
      set := set - set2 ;
    END ;
  END ;
END ParseSet ;

PROCEDURE ParseTokenExpr(p : Parser ; VAR gL, gR: INTEGER) =
  VAR
    gL2, gR2: INTEGER;
    first:    BOOLEAN;
BEGIN
  ParseTokenTerm(p, gL, gR) ;
  first := TRUE ;
  WHILE WeakSeparator(p, Symbol.Bar, 3, 4) DO
    ParseTokenTerm(p, gL2, gR2) ;
    IF first THEN
      CRT.MakeFirstAlt(gL, gR) ;
      first := FALSE
    END ;
    CRT.ConcatAlt(gL, gR, gL2, gR2) ;
  END ;
END ParseTokenExpr ;

PROCEDURE ParseNameDecl(p : Parser) =
  VAR name, str: TEXT;
BEGIN
  ParseIdent(p, name) ;
  Expect(p, Symbol.Equal) ;
  IF (p.next.sym = Symbol.ident) THEN
    Get(p) ;
    name := p.name() ;
  ELSIF (p.next.sym = Symbol.string) THEN
    Get(p) ;
    str := FixString(p) ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in NameDecl") ;
  END ;
  CRT.NewName(name, str) ;
  Expect(p, Symbol.Dot) ;
END ParseNameDecl ;

PROCEDURE ParseTokenDecl(p : Parser ; typ: CRT.NodeType) =
  VAR
   kind:       INTEGER;
   name:       TEXT;
   pos:        CRT.Position;
   sp, gL, gR: INTEGER;
   sn:         CRT.SymbolNode;
BEGIN
  ParseSymbol(p, name, kind) ;
  IF (CRT.FindSym(name) # CRT.noSym) THEN
    p.error("'" & name & "' declared twice")
  ELSE
    sp := CRT.NewSym(typ, name, p.line()) ;
    CRT.GetSym(sp, sn) ;
    sn.struct := ORD(CRT.TokenKind.classToken) ;
    CRT.PutSym(sp, sn)
  END ;
  WHILE (NOT ( (p.next.sym IN SymSet[5]))) DO
    SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in TokenDecl") ;
    Get(p)
  END ;
  IF (p.next.sym = Symbol.Equal) THEN
    Get(p) ;
    ParseTokenExpr(p, gL, gR) ;
    IF (kind # ident) THEN
      p.error("a literal must not be declared within a structure")
    END ;
    CRT.CompleteGraph(gR) ;
    CRA.ConvertToStates(p, gL, sp) ;
    Expect(p, Symbol.Dot) ;
  ELSIF (p.next.sym IN SymSet[6]) THEN
    IF (kind = ident) THEN
      CRT.genScanner := FALSE
    ELSE
      MatchLiteral(p, sp)
    END ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in TokenDecl") ;
  END ;
  IF (p.next.sym = Symbol.sLbrDot) THEN
    ParseSemText(p, pos) ;
    IF (typ = CRT.NodeType.t) THEN
      p.error("semantic action not allowed here")
    END ;
    CRT.GetSym(sp, sn) ;
    sn.semPos := pos ;
    CRT.PutSym(sp, sn) ;
  END ;
END ParseTokenDecl ;

PROCEDURE ParseSetDecl(p : Parser) =
  VAR
    c:    INTEGER;
    set:  CRT.Set;
    name: TEXT;
BEGIN
  ParseIdent(p, name) ;
  c := CRT.ClassWithName(name) ;
  IF (c >= 0) THEN
    p.error("'" & name & "' declared twice")
  END ;
  Expect(p, Symbol.Equal) ;
  ParseSet(p, set) ;
  c := CRT.NewClass(name, set) ;
  Expect(p, Symbol.Dot) ;
END ParseSetDecl ;

PROCEDURE ParseExpression(p : Parser ; VAR gL, gR: INTEGER) =
  VAR gL2, gR2: INTEGER;
      first:    BOOLEAN;
BEGIN
  ParseTerm(p, gL, gR) ;
  first := TRUE ;
  WHILE WeakSeparator(p, Symbol.Bar, 1, 7) DO
    ParseTerm(p, gL2, gR2) ;
    IF (first) THEN
      CRT.MakeFirstAlt(gL, gR) ;
      first := FALSE
    END ;
    CRT.ConcatAlt(gL, gR, gL2, gR2) ;
  END ;
END ParseExpression ;

PROCEDURE ParseSemText(p : Parser ; VAR pos : CRT.Position) =
BEGIN
  Expect(p, Symbol.sLbrDot) ;
  pos.beg := p.offset() + 2 ;
  pos.col := p.column() + 2 ;
  WHILE (p.next.sym IN SymSet[8]) DO
    Get(p) ;
  END ;
  Expect(p, Symbol.sDotRbr) ;
  pos.len := p.offset() - pos.beg ;
END ParseSemText ;

PROCEDURE ParseAttribs(p : Parser ; VAR pos : CRT.Position) =
BEGIN
  Expect(p, Symbol.Less) ;
  pos.beg := p.offset() + 1 ;
  pos.col := 0 ;
  WHILE (p.next.sym IN SymSet[9]) DO
    Get(p) ;
  END ;
  Expect(p, Symbol.Gtr) ;
  pos.len := p.offset() - pos.beg ;
END ParseAttribs ;

PROCEDURE ParseDeclaration(p : Parser) =
  VAR
    gL1, gR1, gL2, gR2: INTEGER;
    nested:             BOOLEAN;
BEGIN
  CASE p.next.sym OF
    Symbol.sCHARACTERS =>
      Get(p) ;
      WHILE (p.next.sym = Symbol.ident) DO
        ParseSetDecl(p) ;
      END ;
  | Symbol.sTOKENS =>
      Get(p) ;
      WHILE (p.next.sym = Symbol.ident) OR
            (p.next.sym = Symbol.string) DO
        ParseTokenDecl(p, CRT.NodeType.t) ;
      END ;
  | Symbol.sNAMES =>
      Get(p) ;
      WHILE (p.next.sym = Symbol.ident) DO
        ParseNameDecl(p) ;
      END ;
  | Symbol.sPRAGMAS =>
      Get(p) ;
      WHILE (p.next.sym = Symbol.ident) OR
            (p.next.sym = Symbol.string) DO
        ParseTokenDecl(p, CRT.NodeType.pr) ;
      END ;
  | Symbol.sCOMMENTS =>
      Get(p) ;
      Expect(p, Symbol.sFROM) ;
      ParseTokenExpr(p, gL1, gR1) ;
      Expect(p, Symbol.sTO) ;
      ParseTokenExpr(p, gL2, gR2) ;
      IF (p.next.sym = Symbol.sNESTED) THEN
        Get(p) ;
        nested := TRUE ;
      ELSIF (p.next.sym IN SymSet[10]) THEN
        nested := FALSE ;
      ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Declaration") ;
      END ;
      CRA.NewComment(p, gL1, gL2, nested) ;
  | Symbol.sIGNORE =>
      Get(p) ;
      IF (p.next.sym = Symbol.sCASE) THEN
        Get(p) ;
        CRT.ignoreCase := TRUE ;
      ELSIF (p.next.sym = Symbol.ident) OR
            (p.next.sym = Symbol.string) OR
            (p.next.sym = Symbol.sANY) OR
            (p.next.sym = Symbol.sCHR) THEN
        ParseSet(p, CRT.ignored) ;
      ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Declaration") ;
      END ;
  ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in Declaration") ;
  END ;
END ParseDeclaration ;

PROCEDURE ParseIdent(p : Parser ; VAR name: TEXT) =
BEGIN
  Expect(p, Symbol.ident) ;
  name := p.name() ;
END ParseIdent ;

PROCEDURE ParseCR(p : Parser) =
  VAR
    ok, undef, hasAttrs: BOOLEAN;
    unknownSy,
    eofSy, gR:       INTEGER;
    gramLine, sp:    INTEGER;
    name, gramName:  TEXT;
    sn:              CRT.SymbolNode;
BEGIN
  Expect(p, Symbol.sCOMPILER) ;
  gramLine := p.line() ;
  eofSy := CRT.NewSym(CRT.NodeType.t, "EOF", 0) ;
  CRT.genScanner := TRUE ;
  CRT.ignoreCase := FALSE ;
  ok := TRUE ;
  CRT.ignored := CRT.Set{} ;
  ParseIdent(p, gramName) ;
  CRT.semDeclPos.beg := p.offset() + p.length() ;
  CRT.semDeclPos.col := 0 ;
  WHILE (p.next.sym IN SymSet[11]) DO
    Get(p) ;
  END ;
  CRT.semDeclPos.len := p.offset() + p.length() - CRT.semDeclPos.beg ;
  WHILE (p.next.sym IN SymSet[12]) DO
    ParseDeclaration(p) ;
  END ;
  WHILE (NOT ( (p.next.sym = Symbol.Eof) OR
            (p.next.sym = Symbol.sPRODUCTIONS))) DO
    SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in CR") ;
    Get(p)
  END ;
  Expect(p, Symbol.sPRODUCTIONS) ;
  IF CRT.genScanner THEN
    CRA.MakeDeterministic(ok)
  END ;
  IF (NOT ok) THEN
    p.error("could not make deterministic automaton")
  END ;
  CRT.nNodes := 0 ;
  WHILE (p.next.sym = Symbol.ident) DO
    ParseIdent(p, name) ;
    sp := CRT.FindSym(name) ;
    undef := (sp = CRT.noSym) ;
    IF (undef) THEN
      sp := CRT.NewSym(CRT.NodeType.nt, name, p.line()) ;
      CRT.GetSym(sp, sn)
    ELSE
      CRT.GetSym(sp, sn) ;
      IF (sn.typ = CRT.NodeType.nt) THEN
        IF (sn.struct > 0) THEN
          p.error("'" & name & "' declared twice")
        END
      ELSE
        p.error("this type not allowed on left side of production")
      END ;
      sn.line := p.line()
    END ;
    hasAttrs := (sn.attrPos.beg >= 0) ;
    IF (p.next.sym = Symbol.Less) THEN
      ParseAttribs(p, sn.attrPos) ;
      IF ((NOT undef) AND (NOT hasAttrs)) THEN
        p.error("symbol earlier referenced without attributes")
      END ;
      CRT.PutSym(sp, sn) ;
    ELSIF (p.next.sym = Symbol.Equal) OR
          (p.next.sym = Symbol.sLbrDot) THEN
      IF ((NOT undef) AND hasAttrs) THEN
        p.error("symbol earlier referenced with attributes")
      END ;
    ELSE SynError(p, "unexpected '" & SymbolName[p.next.sym] & "' in CR") ;
    END ;
    IF (p.next.sym = Symbol.sLbrDot) THEN
      ParseSemText(p, sn.semPos) ;
    END ;
    ExpectWeak(p, Symbol.Equal, 13) ;
    ParseExpression(p, sn.struct, gR) ;
    CRT.CompleteGraph(gR) ;
    CRT.PutSym(sp, sn) ;
    ExpectWeak(p, Symbol.Dot, 14) ;
  END ;
  sp := CRT.FindSym(gramName) ;
  IF (sp = CRT.noSym) THEN
    p.error("missing production for grammar name");
  ELSE
    CRT.GetSym(sp, sn) ;
    IF (sn.attrPos.beg >= 0) THEN
      p.error("grammar symbol must not have attributes")
    END ;
    CRT.root := CRT.NewNode(CRT.NodeType.nt, sp, gramLine) ;
  END ;
  Expect(p, Symbol.sEND) ;
  ParseIdent(p, name) ;
  IF (NOT Text.Equal(name, gramName)) THEN
    p.error("name does not match name in heading")
  END ;
  Expect(p, Symbol.Dot) ;
  unknownSy := CRT.NewSym(CRT.NodeType.t, "*Undef*", 0) ;
END ParseCR ;


PROCEDURE Parse(p : Parser) RAISES { Rd.Failure, Thread.Alerted } =
BEGIN
  Get(p) ;
  ParseCR(p) ;
END Parse ;

PROCEDURE Init(p : Parser ; s : Scanner ; e : ErrHandler) : Parser =
BEGIN
  p.s       := s ;
  p.err     := e ;
  p.errDist := minErrDist ;
  RETURN p
END Init ;

BEGIN
END CRP.
