%{
#include <stdlib.h>
#include <stdio.h>
%}

%union {int nb ; char * var;}
%token tCON tINT tMAIN tPRINT tCOL tEQUAL tOP tCP tOCB tCCB tSUB tADD tDIV tMUL tERR
%token <nb> tNB
%token <var> tVAR
%start Main
%type <nb> Expr DivMul Term 

%%

Main : tMAIN tOP tCP tOCB Body tCCB 

Body : Declarations Attributions Instructions

Declarations : tCON tVAR tEQUAL Expr tCOL {printf("const %s = %d\n", $2, $4);}
      | tINT tVAR tCOL {printf("int %s\n", $2);}
      | tINT Attributions {printf("int");}
      | {};

Attributions : tVAR tEQUAL Expr tCOL {printf("%s = %d\n", $1, $3);}
      | {};

Instructions : tPRINT tOP tVAR tCP tCOL Instructions {printf("%s\n", $3);}
      | {};


Expr :		  Expr tADD DivMul { $$ = $1 + $3; }
		| Expr tSUB DivMul { $$ = $1 - $3; }
		| DivMul { $$ = $1; } ;
DivMul :	  DivMul tMUL Term { $$ = $1 * $3; }
		| DivMul tDIV Term { $$ = $1 / $3; }
		| Term { $$ = $1; } ;
Term :		  tOP Expr tCP { $$ = $2; }
		| tVAR { $$ = 4; }
		| tNB { $$ = $1; } ;

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("Compiler\n"); // yydebug=1;
  yyparse();
  return 0;
}