%option noyywrap

%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"
%}

%%

[ \t]+	{/*return tSEP;*/}
"ADD" {return tADD;}
"MUL" {return tMUL;}
"SUB" {return tSUB;}
"DIV" {return tDIV;}
"COP" {return tCOP;}
"AFC" {return tAFC;}
"JMP" {return tJMP;}
"JMF" {return tJMF;}
"INF" {return tINF;}
"SUP" {return tSUP;}
"EQU" {return tEQU;}
"PRI" {return tPRI;}
[0-9]+	{
	  yylval.nb = atoi(yytext);
	  return tVAL;
	}
\n	{ return tEOL; }
.	{ return tERR; }

%%