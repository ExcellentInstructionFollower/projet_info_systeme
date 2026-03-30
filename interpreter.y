%{
#define NB_ADDRESS 0x1000

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char *s);

int addresses[NB_ADDRESS]; 

%}

%union {int nb ;}
%token tADD tMUL tSUB tDIV tCOP tAFC tJMP tJMF tINF tSUP tEQU tPRI tEOL tERR
%token <nb> tVAL
%start Code

%% 

Code: Instruction Code
      | {return 0;};

Instruction : Action tEOL | tEOL ;

Action : 
    tADD tVAL tVAL tVAL { addresses[$2] = addresses[$3] + addresses[$4]; } |   
    tMUL tVAL tVAL tVAL { addresses[$2] = addresses[$3] * addresses[$4]; } |   
    tSUB tVAL tVAL tVAL { addresses[$2] = addresses[$3] - addresses[$4]; } |   
    tDIV tVAL tVAL tVAL { addresses[$2] = addresses[$3] / addresses[$4]; } |   
    tCOP tVAL tVAL { addresses[$2] = addresses[$3] ; } |   
    tAFC tVAL tVAL { addresses[$2] = $3 ; } |   
    tJMP tVAL { addresses[$2] = 0 ; } |   
    tJMF tVAL tVAL { if (addresses[$2]) addresses[$2] = 0 ; } |  
    tINF tVAL tVAL tVAL { addresses[$2] = addresses[$3] < addresses[$4] ; } |   
    tSUP tVAL tVAL tVAL { addresses[$2] = addresses[$3] > addresses[$4] ; } |   
    tEQU tVAL tVAL tVAL { addresses[$2] = addresses[$3] == addresses[$4] ; } |   
    tPRI tVAL { printf("%d\n", addresses[$2]) ; } |   

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s);}

int main(void) {

    FILE * f_asm = fopen("f_asm", "r");
    if (f_asm != NULL) yyrestart(f_asm);

    printf("Interpreter\n"); // yydebug=1;
    yyparse();
       
    fclose(f_asm);

    return 0;
}