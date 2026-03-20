%option noyywrap

%{
#include <stdlib.h>
#include <stdio.h>
%}

%%

[, \t]+	{printf("tSEP : %s ", yytext);};
"int" {printf("tINT ");}
"const" {printf("tCON ");}
"main" {printf("tMAIN ");}
"printf" {printf("tPRINT ");}
[0-9]+	{printf("tNB : %s ", yytext);
	  /*yylval.nb = atoi(yytext);
	  return tNB;*/
	}
([0-9]+)e([0-9]+) {printf("tNB : %s ", yytext);
	  /*yylval.nb = atoi(yytext);
	  return tNB;*/
	}
"="	{ printf("tEQUAL "); /*return tEQUAL;*/ }
"-"	{ printf("tSUB "); /*return tSUB;*/ }
"+"	{ printf("tADD "); /*return tADD;*/}
"*"	{ printf("tMUL "); /*return tMUL;*/ }
"/"	{ printf("tDIV "); /*return tDIV;*/ }
"("	{ printf("tOP "); /*return tOP;*/ }
")"	{ printf("tCP "); /*return tCP;*/ }
"{"	{ printf("tOCB "); /*return tOP;*/ }
"}"	{ printf("tCCB "); /*return tCP;*/ }
[A-Za-z][A-Za-z0-9_]*	{ printf("tVAR : %s ", yytext);
	  /*yylval.var = yytext[0];
	  return tVAR;*/
	}
";" { printf("tCOL ");}
\n	{ printf("tEOL \n"); /*return tEOL;*/ }
.	{ printf("tERR "); /*return tERR;*/ }

%%

int main(void) {
  printf("Compiler\n"); // yydebug=1;
  yylex();
  return 0;
}