%{
#define NB_VARIABLES 256
#define START_VAR_ADDR 0x1000000

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char *s);

const int STACK_BASE = 0xFFFF;
int stack_pointer = STACK_BASE; 
int last_addr = START_VAR_ADDR;

struct node {
      char * label;
      int addr;
      struct node * next;
};

int var_hash(char * var_name) {
  int res = 0;
  int i = 0;
  while (i<8 && var_name[i] != '\0') {
    res += var_name[i]*i;
    i++;
  }
  return res % NB_VARIABLES;
}

struct node * variables[NB_VARIABLES];

int insert(char * var_name) {
      int hash = var_hash(var_name);
      struct node * new_start = malloc(sizeof(struct node));
      new_start->label = strdup(var_name);
      new_start->addr = last_addr++;
      new_start->next = variables[hash];
      variables[hash] = new_start;
      return last_addr-1;
}

int get(char * var_name) {
      int hash = var_hash(var_name);
      struct node * cur_node = variables[hash];
      while (cur_node != NULL) {
            if (strcmp(var_name, cur_node->label) == 0) {
                  return cur_node->addr;
            }
      }
      return -1;
}

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
      |tCCB {return 0;};

Instruction : Declaration tCOL
      |Attribution tCOL
      |Call tCOL ;

Declaration : tCON ConstChain  
      | tINT IntChain;

ConstChain : tVAR tEQUAL Expr ConstChain {printf("const %s = %d\n", $1, $3);
                                          insert($1);}
      | ;

IntChain : tVAR IntChain {printf("int %s\n", $1); printf("insert = %d\n", insert($1));}
      | tVAR tEQUAL Expr IntChain {printf("int %s = %d\n", $1, $3);
                                    insert($1);}
      | ;

Attribution : tVAR tEQUAL Expr {printf("%s = %d\n", $1, $3);
                              printf("get(%s) = %d\n", $1, get($1));};

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