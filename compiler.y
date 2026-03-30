%{
#define NB_VARIABLES 256
#define START_VAR_ADDR 0x1
#define WRITE_SIZE 32
#define STACK_BASE 0xFFF

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char *s);

int stack_pointer = STACK_BASE; 
int last_addr = START_VAR_ADDR;

FILE * f_asm;
FILE * f_opcode;

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

void asm_write(int op, int result, int op1, int op2) {
      char buffer_asm[WRITE_SIZE];
      char buffer_op[WRITE_SIZE];

      switch (op) {
            case 1:  //ADD
                  sprintf(buffer_asm, "ADD %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "1 %d %d %d\n", result, op1, op2);
                  break;
            case 2:  //MUL
                  sprintf(buffer_asm, "MUL %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "2 %d %d %d\n", result, op1, op2);
                  break;
            case 3:  //SUB
                  sprintf(buffer_asm, "SUB %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "3 %d %d %d\n", result, op1, op2);
                  break;
            case 4:  //DIV
                  sprintf(buffer_asm, "DIV %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "4 %d %d %d\n", result, op1, op2);
                  break;
            case 5:  //COP
                  sprintf(buffer_asm, "COP %d %d\n", result, op1);
                  sprintf(buffer_op, "5 %d %d\n", result, op1);
                  break;
            case 6:  //AFC
                  sprintf(buffer_asm, "AFC %d %d\n", result, op1);
                  sprintf(buffer_op, "6 %d %d\n", result, op1);
                  break;
            case 7:  //JMP
                  sprintf(buffer_asm, "JMP %d\n", result);
                  sprintf(buffer_op, "7 %d\n", result);
                  break;
            case 8:  //JMF
                  sprintf(buffer_asm, "JMF %d %d\n", result, op1);
                  sprintf(buffer_op, "8 %d %d\n", result, op1);
                  break;
            case 9:  //INF
                  sprintf(buffer_asm, "INF %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "9 %d %d %d\n", result, op1, op2);
                  break;
            case 10: //SUP
                  sprintf(buffer_asm, "SUP %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "10 %d %d %d\n", result, op1, op2);
                  break;
            case 11: //EQU
                  sprintf(buffer_asm, "EQU %d %d %d\n", result, op1, op2);
                  sprintf(buffer_op, "11 %d %d %d\n", result, op1, op2);
                  break;
            case 12: //PRI
                  sprintf(buffer_asm, "PRI %d\n", result);
                  sprintf(buffer_op, "12 %d\n", result);
                  break;

      }
      fprintf(f_asm, "%s", buffer_asm);
      fprintf(f_opcode, "%s", buffer_op);   
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

ConstChain : tVAR tEQUAL Expr ConstChain {asm_write(5, insert($1), ++stack_pointer, 0);}
      | ;

IntChain : tVAR IntChain {insert($1);}
      | tVAR tEQUAL Expr IntChain {asm_write(5, insert($1), ++stack_pointer, 0);}
      | ;

Attribution : tVAR tEQUAL Expr {asm_write(5, get($1), ++stack_pointer, 0);};

Call : tPRINT tOP tVAR tCP {asm_write(12, get($3), 0, 0);};


Expr :      Expr tADD DivMul { stack_pointer++ ; 
                                    asm_write(1, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| Expr tSUB DivMul { stack_pointer++ ; 
                                    asm_write(3, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| DivMul { } ;
DivMul :	  DivMul tMUL Term { stack_pointer++ ; 
                                    asm_write(2, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| DivMul tDIV Term { stack_pointer++ ; 
                                    asm_write(4, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| Term { } ;
Term :		  tOP Expr tCP { }
		| tVAR { asm_write(5, stack_pointer--, get($1), 0); }
		| tNB { asm_write(6, stack_pointer--, $1, 0); } ;

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s);}

int main(void) {

      for (int i=0;i<NB_VARIABLES;i++) variables[i] = NULL;
      f_asm = fopen("f_asm", "w");
      f_opcode = fopen("f_opcode", "w");

      printf("Compiler\n"); // yydebug=1;
      yyparse();

      for (int j=0;j<NB_VARIABLES;j++) { 
            struct node * next_node = variables[j];
            struct node * node_to_free;
            while (next_node != NULL) {
                  node_to_free = next_node;
                  next_node = next_node->next;
                  free(node_to_free);
            } 
      } 

      fclose(f_asm);
      fclose(f_opcode);
      return 0;
}