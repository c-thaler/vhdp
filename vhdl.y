%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string>

  #include "bison_def.h"
  #include "backend.h"

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
 
  void yyerror(const char *s);
%}

%union {
  std::string *str; /* String */
  int n; /* Value */
}

%token LIBRARY USE
%token ENTITY ARCHITECTURE PROCESS
%token CASE FOR LOOP GENERATE
%token OF IS
%token IF THEN
%token TO DOWNTO
%token BEGN END
%token PORT IN OUT
%token SIGNAL VARIABLE
%token XOR AND OR NOT CONCAT
%token S_ASSIGN V_ASSIGN

%token <str> NAME
%token LITERAL CHAR VECT

%%
vhdl:
      header entity architecture
    | entity architecture
    | entity
    | architecture
    ;

header:
      header library
    | header use
    | library
    | use
    ;

library:
    LIBRARY NAME ';'
    ;

use:
    USE qual_name ';'
    ;

qual_name:
      qual_name '.' NAME
    | NAME
    ;

entity:
    ENTITY NAME IS portlist ';' END NAME ';' {vhdp_entity($2);}
    ;

portlist:
    PORT '(' ports ')'
    ;

ports:
      ports ';' port
    | port
    ;

port:
    namelist ':' direction type
    ;

type:
      NAME
    | NAME '(' range ')'
    ;

signal:
      NAME
    | NAME '(' range ')'
    ;

range:
      simple_expr
    | simple_expr DOWNTO simple_expr
    | simple_expr TO simple_expr
    ;

namelist:
      namelist ',' NAME
    | NAME
    ;

direction:
      IN
    | OUT
    ;

architecture:
    ARCHITECTURE NAME OF NAME IS BEGN arch_body END NAME ';' {vhdp_arch();}
    ;

arch_body:
      arch_body arch_line
    | arch_line
    ;

arch_line:
      signal_assign
    | process
    ;

process:
      PROCESS '(' sens_list ')' declarations BEGN proc_body END PROCESS ';'
    ;

sens_list:
      sens_list ',' NAME
    | NAME
    ;

declarations:
      declarations declaration
    | declaration
    ;

declaration:
      SIGNAL NAME ':' type ';'
    | VARIABLE NAME ':' type ';'
    ;

proc_body:
      proc_body proc_line
    | proc_line
    ;

proc_line:
    variable_assign
    | signal_assign
    | for_loop
    | if_then
    ;

signal_assign:
    signal S_ASSIGN expr ';'
    ;

variable_assign:
    signal V_ASSIGN expr ';'
    ;

expr:
      '(' expr ')'
    | expr AND expr
    | expr OR expr
    | expr XOR expr
    | expr '&' expr
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | CHAR
    | VECT
    | signal
    | LITERAL
    ;

simple_expr:
      '(' simple_expr ')'
    | simple_expr '+' simple_expr
    | simple_expr '-' simple_expr
    | simple_expr '*' simple_expr
    | simple_expr '/' simple_expr
    | LITERAL
    ;

for_loop:
    FOR NAME IN range LOOP proc_body END LOOP ';'
    ;

if_then:
    IF bool_expr THEN proc_body END IF ';'
    ;

bool_expr:
      expr '=' expr
    | expr '<' expr
    | expr '>' expr
    ;
%%

int vhdp_parse_file(FILE *file) {
  // Set Flex to read from it instead of defaulting to STDIN:
  yyin = file;
  //yydebug = 1;

  // Parse through the input:
  yyparse();  
}

void yyerror(const char *s) {
  printf("EEK, parse error!  Message: %s\n", s);
  exit(-1);
}
