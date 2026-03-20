%{
#include <stdlib.h>
#include <stdio.h>
void yyerror(char *s);

const int STACK_BASE = 0xFFFF;
int stack_pointer = STACK_BASE; 



const int NB_VARIABLES = 256;

int var_hash(char * var_name) {
  int res = 0;
  int i = 0;
  while (i<8 && var_name[i] != '\0') {
    res += var_name[i]*i;
    i++;
  }
  return res % NB_VARIABLES;
}



int variables[NB_VARIABLES];
%}

%union {int nb ; char * var;}
%token tCON tINT tMAIN tPRINT tCOL tEQUAL tOP tCP tOCB tCCB tSUB tADD tDIV tMUL tERR
%token <nb> tNB
%token <var> tVAR
%start Main
%type <nb> Expr DivMul Term 

%%

Main : tMAIN tOP tCP tOCB Body  

Body : Instruction Body 
      |tCCB;

Instruction : Declaration tCOL
      |Attribution tCOL
      |Call tCOL ;

Declaration : tCON ConstChain  {printf("const %s = %d\n", $2, $4);}
      | tINT IntChain {printf("int %s = %d\n", $2, $4);};

ConstChain : tVAR tEQUAL Expr ConstChain
      | ;

IntChain : tVAR IntChain
      | tVAR tEQUAL Expr IntChain
      | ;

Attribution : tVAR tEQUAL Expr {printf("%s = %d\n", $1, $3);};

Call : tPRINT tOP tVAR tCP tCOL {printf("%s\n", $3);};


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