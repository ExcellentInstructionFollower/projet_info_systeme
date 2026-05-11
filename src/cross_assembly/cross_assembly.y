%{
#define NB_VARIABLES 256
#define NB_REGISTERS 16
#define WRITE_SIZE 32

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char *s);

int variable_positions[NB_VARIABLES]; 
int register_age[NB_REGISTERS];
int register_content[NB_REGISTERS];

FILE * f_opcode_register;

// void jump(int line) {
//     FILE * f_asm = fopen("f_asm", "r");
//     fseek(f_asm, line*WRITE_SIZE-1, SEEK_SET); 
//     yyrestart(f_asm);
// }

//LOAD : 13
//STORE : 14

int oldest_register(void) {
    int max_age = -1;
    int max_index = -1;
    for (int i = 0; i<NB_REGISTERS; i++){
        if (max_age < register_age[i]) {
            max_age = register_age[i];
            max_index = i;
        }
    }
    return max_index;
}

void increment_ages(void) {
    for (int i = 0; i<NB_REGISTERS; i++){
        register_age[i]++;
    }
}

void asm_print(op, result, op1, op2) {
    char buffer_asm[34];
    sprintf(buffer_asm, "%2x%2x%2x%2x\n", op, result, op1, op2);
    for (int i = 0;i<34;i++) {
        if (buffer_asm[i] == ' ') {
            buffer_asm[i] = '0';
        }
    }
    fprintf(f_opcode_register, "%s", buffer_asm);
}

void asm_convert(int op, int result, int op1, int op2, int nb_ops) {
    int new_ops[3] = {result, op1, op2};

    for (int i = 0; i<nb_ops ; i++) {

        increment_ages();

        if (variable_positions[new_ops[i]] == -1 || variable_positions[new_ops[i]] == 16) {
            int new_position = oldest_register();

            if (register_content[new_position] != -1) {
                asm_print(14, register_content[new_position],new_position,0);
                variable_positions[register_content[new_position]] = 16;
            }

            if (variable_positions[new_ops[i]] == 16) {
                asm_print(13, new_position,new_ops[i],0);
            }
            variable_positions[new_ops[i]] = new_position;
            register_content[new_position] = new_ops[i];
            register_age[new_position] = 0;
        }

        new_ops[i] = variable_positions[new_ops[i]];
    }

    

    asm_print(op, new_ops[0], new_ops[1], new_ops[2]);   
}

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
    tADD tVAL tVAL tVAL { asm_convert(1,$2,$3,$4,3); } |   
    tMUL tVAL tVAL tVAL { asm_convert(2,$2,$3,$4,3); } |   
    tSUB tVAL tVAL tVAL { asm_convert(3,$2,$3,$4,3); } |   
    tDIV tVAL tVAL tVAL { asm_convert(4,$2,$3,$4,3); } |   
    tCOP tVAL tVAL { asm_convert(5,$2,$3,0,2); } |   
    tAFC tVAL tVAL { asm_convert(6,$2,$3,0,1); } |   
    tJMP tVAL { asm_convert(7,$2,0,0,1); } |   
    tJMF tVAL tVAL { asm_convert(8,$2,$3,0,2);} |  
    tINF tVAL tVAL tVAL { asm_convert(9,$2,$3,$4,3); } |   
    tSUP tVAL tVAL tVAL { asm_convert(10,$2,$3,$4,3); } |   
    tEQU tVAL tVAL tVAL { asm_convert(11,$2,$3,$4,3); } |   
    tPRI tVAL { asm_convert(12,$2,0,0,1); } ;  

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s);}

int main(void) {

    FILE * f_asm = fopen("f_asm", "r");
    if (f_asm != NULL) yyrestart(f_asm);

    f_opcode_register = fopen("f_opcode_register", "w");

    for (int i = 0;i<NB_VARIABLES;i++) {
        variable_positions[i] = -1;
    }
    for (int i = 0;i<NB_REGISTERS;i++) {
        register_age[i] = 0;
        register_content[i] = -1;
    }

    printf("Cross Assembly\n"); // yydebug=1;
    yyparse();
       
    fclose(f_asm);

    return 0;
}