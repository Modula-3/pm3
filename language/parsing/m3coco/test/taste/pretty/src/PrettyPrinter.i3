INTERFACE PrettyPrinter;
(* Pretty printing auxiliary functions for use with CLANG pretty printing
   program generated by COCO from an attributed grammar
   P.D. Terry, Rhodes University, 17 May 1991 *)

IMPORT Wr ;

VAR
  results : Wr.T ;

PROCEDURE Append(String : TEXT) ;
  (* Append String to results file *)

PROCEDURE IndentNextLine() ;
  (* Write line mark to results file and prepare to indent further lines
     by two spaces more than before *)

PROCEDURE ExdentNextLine() ;
  (* Write line mark to results file and prepare to indent further lines
     by two spaces less *)

PROCEDURE NewLine() ;
  (* Write line mark to results file but leave indentation as before *)

PROCEDURE Indent() ;
PROCEDURE Exdent() ;

END PrettyPrinter.
