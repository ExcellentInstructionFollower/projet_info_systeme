%option noyywrap

%{
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "y.tab.h"
%}

%%

[, \t]+	{/*return tSEP;*/}
"int" {return tINT;}
"const" {return tCON;}
"main" {return tMAIN;}
"printf" {return tPRINT;}
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
"("	{ return tOP; }
")"	{ return tCP; }
"{"	{ return tOCB; }
"}"	{ return tCCB; }
[A-Za-z][A-Za-z0-9_]*	{
	  yylval.var = strdup(yytext);
	  return tVAR;
	}
";" { return tCOL;}
\n	{ /*return tEOL;*/ }
.	{ return tERR; }

%%

/*int main(void) {
  printf("Compiler\n"); // yydebug=1;
  yylex();
  return 0;
}*/