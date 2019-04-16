%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string>
  #include <list>
  #include <iostream>

  #include "bison_def.h"
  #include "backend.h"
  #include "Port.h"
  #include "Entity.h"

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylineno;  // defined and maintained in lex
  extern char *yytext;  // defined and maintained in lex
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;

  Entity *result_entity = nullptr;
  Entity *result_arch = nullptr;
 
  void yyerror(const char *s);
%}

%code requires {
  #include "Port.h"
  #include "Entity.h"
}

%union {
  std::string *str; /* String */
  int n; /* Value */

  Entity *e;
  Port *p;

  std::list<std::string*> *sl; /* String list */
  std::list<Port*> *pl; /* Port list */
}

%token LIBRARY USE
%token ENTITY ARCHITECTURE PROCESS
%token CASE FOR LOOP GENERATE
%token OF IS
%token IF THEN
%token TO DOWNTO
%token BEGN END
%token <pl> PORT
%token <n> IN OUT INOUT
%token SIGNAL VARIABLE
%token XOR AND OR NOT CONCAT
%token S_ASSIGN V_ASSIGN

%token <str> NAME
%token LITERAL CHAR VECT

%type <n> direction
%type <str> type
%type <sl> namelist
%type <pl> portlist port ports
%type <e> entity

%%
vhdl_file:
    vhdl_file vhdl_top
    | vhdl_top
    ;

vhdl_top:
    header
    | entity {
      result_entity = $1;
    }
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
    ENTITY NAME IS portlist ';' entity_end ';' {
      $$ = new Entity($2, $4);
    }
    ;

entity_end:
    END ENTITY NAME
    | END ENTITY
    | END NAME
    | END
    ;

portlist:
    PORT '(' ports ')' {
      $$ = $3;
    }
    ;

ports:
    ports ';' port {
      $1->splice($1->end(), *$3);
      $$ = $1;

      for(Port *p : *$1) {
      }
    }
    | port
    ;

port:
    namelist ':' direction type {
      std::list<Port*> *pl = new std::list<Port*>;

      for(std::string *name : *$1) {
        pl->push_front(new Port(name, (Direction) $3, $4));
      }

      $$ = pl;
    }
    ;

type:
      NAME
    | NAME '(' rangelist ')'
    ;

signal:
      NAME
    | NAME '(' rangelist ')'
    ;

rangelist:
    rangelist ',' range
    | range 

range:
    simple_expr
    | simple_expr DOWNTO simple_expr
    | simple_expr TO simple_expr
    ;

namelist:
    namelist ',' NAME {
        $1->push_front($3);
      }
    | NAME {
        std::list<std::string*> *sl = new std::list<std::string*>;
        sl->push_back($1);

        $$ = sl;
    }
    ;

direction:
      IN    {$$ = DIR_IN;}
    | OUT   {$$ = DIR_OUT;}
    | INOUT {$$ = DIR_INOUT;}
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
    | NAME
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

  #ifdef BISON_DEBUG
  yydebug = 1;
  #endif

  // Parse through the input:
  yyparse();  
}

void yyerror(const char *s) {
  fprintf(stderr, "ERROR: %s at token '%s' on line %d\n", s, yytext, yylineno);
  exit(-1);
}
