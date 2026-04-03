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
int cur_instr_number = 0;

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
            cur_node = cur_node->next;
      }
      return -1;
}

void asm_write(int op, int result, int op1, int op2) {
      char buffer_asm[WRITE_SIZE];
      char buffer_op[WRITE_SIZE];
      int end_line_asm = 0;
      int end_line_op = 0;

      switch (op) {
            case 1:  //ADD
                  end_line_asm = sprintf(buffer_asm, "ADD %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "1 %d %d %d", result, op1, op2);
                  break;
            case 2:  //MUL
                  end_line_asm = sprintf(buffer_asm, "MUL %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "2 %d %d %d", result, op1, op2);
                  break;
            case 3:  //SUB
                  end_line_asm = sprintf(buffer_asm, "SUB %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "3 %d %d %d", result, op1, op2);
                  break;
            case 4:  //DIV
                  end_line_asm = sprintf(buffer_asm, "DIV %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "4 %d %d %d", result, op1, op2);
                  break;
            case 5:  //COP
                  end_line_asm = sprintf(buffer_asm, "COP %d %d", result, op1);
                  end_line_op = sprintf(buffer_op, "5 %d %d", result, op1);
                  break;
            case 6:  //AFC
                  end_line_asm = sprintf(buffer_asm, "AFC %d %d", result, op1);
                  end_line_op = sprintf(buffer_op, "6 %d %d", result, op1);
                  break;
            case 7:  //JMP
                  end_line_asm = sprintf(buffer_asm, "JMP %d", result);
                  end_line_op = sprintf(buffer_op, "7 %d", result);
                  break;
            case 8:  //JMF
                  end_line_asm = sprintf(buffer_asm, "JMF %d %d", result, op1);
                  end_line_op = sprintf(buffer_op, "8 %d %d", result, op1);
                  break;
            case 9:  //INF
                  end_line_asm = sprintf(buffer_asm, "INF %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "9 %d %d %d", result, op1, op2);
                  break;
            case 10: //SUP
                  end_line_asm = sprintf(buffer_asm, "SUP %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "10 %d %d %d", result, op1, op2);
                  break;
            case 11: //EQU
                  end_line_asm = sprintf(buffer_asm, "EQU %d %d %d", result, op1, op2);
                  end_line_op = sprintf(buffer_op, "11 %d %d %d", result, op1, op2);
                  break;
            case 12: //PRI
                  end_line_asm = sprintf(buffer_asm, "PRI %d", result);
                  end_line_op = sprintf(buffer_op, "12 %d", result);
                  break;

      }

      for(int i=end_line_asm ; i<WRITE_SIZE ; i++) {
            buffer_asm[i] = ' ';
      }
      for(int i=end_line_op ; i<WRITE_SIZE ; i++) {
            buffer_op[i] = ' ' ;
      }
      buffer_asm[WRITE_SIZE - 1] = '\0';
      buffer_op[WRITE_SIZE - 1] = '\0';
      fprintf(f_asm, "%s\n", buffer_asm);
      fprintf(f_opcode, "%s\n", buffer_op);   
      cur_instr_number++;
}


enum SCOPE_TYPE{GENERIC, SCOPE_IF, SCOPE_WHILE};

struct scope_node {
      long start_pos_asm; //the starting position of the scope in the file f_asm
                  //(AFTER calculating any condition that may be present)
      long start_pos_opcode;
      int start_instruction; //the instruction number of the start of the scope 
                  //(BEFORE checking conditions)
      int type; //the scope's type, see above the SCOPE_TYPE enum
      struct scope_node * contained_in;
};

enum SCOPE_TYPE next_scope_type = GENERIC;
int next_scope_start_instr = 0;
struct scope_node * scope_stack = NULL;

void begin_new_scope(enum SCOPE_TYPE type) {
      struct scope_node * new_scope = malloc(sizeof(struct scope_node));
      new_scope->start_pos_asm = ftell(f_asm);
      new_scope->start_pos_opcode = ftell(f_opcode);
      new_scope->start_instruction = next_scope_start_instr;
      new_scope->type = type;
      new_scope->contained_in = scope_stack;

      asm_write(0, 0, 0, 0); //padding for the jump that will be added later

      scope_stack = new_scope;
} 

void end_scope() {

      struct scope_node * cur_scope = scope_stack;

      if (cur_scope->type == SCOPE_WHILE) {
            asm_write(7, cur_scope->start_instruction, 0, 0);
      } 

      if (cur_scope->type == SCOPE_IF || cur_scope->type == SCOPE_WHILE ) {
            long cur_pos_asm = ftell(f_asm);
            long cur_pos_opcode = ftell(f_opcode);
            fseek(f_asm, cur_scope->start_pos_asm, SEEK_SET);
            fseek(f_opcode, cur_scope->start_pos_opcode, SEEK_SET);
            asm_write(8, ++stack_pointer, cur_instr_number, 0);
            fseek(f_asm, cur_pos_asm, SEEK_SET);
            fseek(f_opcode, cur_pos_opcode, SEEK_SET);
      }  

      scope_stack = cur_scope->contained_in;
      free(cur_scope);
} 

%}

%union {int nb ; char * var;}
%token tCON tINT tIF tWHL tMAIN tPRINT tCOL tEQUAL tOP tCP tOCB tCCB tSUB tADD tDIV tMUL tINF tSUP tEQTO tERR
%token <nb> tNB
%token <var> tVAR
%start Main
%type <nb> Expr  
%left tADD tSUB
%left tDIV tMUL

%%

Main : tMAIN tOP tCP Scope {return 0;} ;

Scope : ScopeStart Body tCCB {end_scope();} ; 

ScopeStart : tOCB {begin_new_scope(next_scope_type);} ;  

Body : Instruction Body 
      | IfStart tOP Condition tCP Scope Body
      | WhileStart tOP Condition tCP Scope Body
      | ;

IfStart : tIF {next_scope_type = SCOPE_IF;
                  next_scope_start_instr = cur_instr_number;} ;

WhileStart :  tWHL {next_scope_type = SCOPE_WHILE;
                        next_scope_start_instr = cur_instr_number;} ;

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

Condition : Expr tINF Expr { stack_pointer++ ; 
                                    asm_write(9, stack_pointer+1, stack_pointer+1, stack_pointer); }
            | Expr tSUP Expr { stack_pointer++ ; 
                                    asm_write(10, stack_pointer+1, stack_pointer+1, stack_pointer); } 
            | Expr tEQTO Expr { stack_pointer++ ; 
                                    asm_write(11, stack_pointer+1, stack_pointer+1, stack_pointer); } ;

Expr :      Expr tADD Expr { stack_pointer++ ; 
                                    asm_write(1, stack_pointer+1, stack_pointer+1, stack_pointer); }
            | Expr tMUL Expr { stack_pointer++ ; 
                                    asm_write(2, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| Expr tSUB Expr { stack_pointer++ ; 
                                    asm_write(3, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| Expr tDIV Expr { stack_pointer++ ; 
                                    asm_write(4, stack_pointer+1, stack_pointer+1, stack_pointer); }
		| tOP Expr tCP { }
		| tVAR { asm_write(5, stack_pointer--, get($1), 0); }
		| tNB { asm_write(6, stack_pointer--, $1, 0); } ;

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s);}

int main(void) {

      for (int i=0;i<NB_VARIABLES;i++) variables[i] = NULL;
      f_asm = fopen("f_asm", "w");
      f_opcode = fopen("f_opcode", "w");

      FILE * f_code = fopen("f_c_code", "r");
      if (f_code != NULL) yyrestart(f_code);

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