%option noyywrap

%{
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "y.tab.h"
%}

%%

[, \t \n]+	{}
"int" { return tINT;}
"void" { return tVOID; }
"const" { return tCON;}
"if" { return tIF;}
"while" { return tWHL;}   
"main" { return tMAIN;}
"printf" { return tPRINT;}
([0-9]+)e([0-9]+) {
        int i = 0;
        while (yytext[i] != 'e') {i++;}
        
        yytext[i] = '\0';
        int mantissa = atoi(yytext);
        int exponent = atoi(yytext + i + 1);
        for (int i=0;i<exponent;i++){
            mantissa *= 10;
        }
        yylval.nb = mantissa ;

        return tNB;
	}
[0-9]+	{
	  yylval.nb = atoi(yytext);
	  return tNB;
	}
"="	{ return tEQUAL; }
"-"	{ return tSUB; }
"+"	{ return tADD; }
"*"	{ return tMUL; }
"/"	{ return tDIV; }
"<" { return tINF; } 
">" { return tSUP; } 
"==" { return tEQTO;} 
"&" { return tAMP; }
"("	{ return tOP; }
")"	{ return tCP; }
"{"	{ return tOCB; }
"}"	{ return tCCB; }
"/*" { return tOCOM; }
"*/" { return tCCOM; }
"NULL" { return tNULL; }
[A-Za-z][A-Za-z0-9_]*	{
	  yylval.var = strdup(yytext);
	  return tVAR;
	}
";" { return tCOL;}
.	{ return tERR; }

%%

/*int main(void) {
  printf("Compiler\n"); // yydebug=1;
  yylex();
  return 0;
}*/