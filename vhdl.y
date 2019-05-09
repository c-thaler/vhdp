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
  #include "Arch.h"

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylineno;  // defined and maintained in lex
  extern char *yytext;  // defined and maintained in lex
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;

  Entity *result_entity = nullptr;
  Arch *result_arch = nullptr;
 
  void yyerror(const char *s);
%}

%code requires {
  #include "Port.h"
  #include "Entity.h"
  #include "Arch.h"
}

%union {
  std::string *str; /* String */
  int n; /* Value */

  Entity *e;
  Port *p;
  Arch *a;

  std::list<std::string*> *sl; /* String list */
  std::list<Port*> *pl; /* Port list */
}

%token LIBRARY USE
%token ENTITY ARCHITECTURE PROCESS
%token CASE FOR LOOP GENERATE
%token OF IS
%token IF THEN ELSE WHEN
%token TO DOWNTO
%token BEGN END
%token GENERIC
%token <pl> PORT
%token <n> IN OUT INOUT
%token SIGNAL VARIABLE CONSTANT
%token XOR AND OR NOT CONCAT
%token S_ASSIGN V_ASSIGN ASSOC
%token OTHERS RANGE

%token <str> ID
%token LITERAL CHAR VECT

%left AND OR XOR
%left '=' '<' '>'
%left '+' '-'
%left '*' '/'
%left '&'

%type <n> direction
%type <str> type
%type <sl> idlist
%type <pl> portlist port ports
%type <e> entity
%type <a> architecture

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
    | architecture {
      result_arch = $1;
    }
    ;

header:
    library
    | use
    ;

library:
    LIBRARY ID ';'
    ;

use:
    USE ID ';'
    ;

name:
    ID
    | name_param
    ;

name_param:
    ID '(' param ')'
    ;

param:
    expr
    | range
    ;

entity:
    ENTITY ID IS portlist ';' entity_end ';' {
      $$ = new Entity($2, $4);
    }
    | ENTITY ID IS genericlist ';' portlist ';' entity_end ';' {
      $$ = new Entity($2, $6);
    }
    ;

entity_end:
    END ENTITY ID
    | END ENTITY
    | END ID
    | END
    ;

genericlist:
    GENERIC '(' generics ')'
    ;

generics:
    generics ';' generic
    | generic
    ;

generic:
    idlist ':' type
    | idlist ':' type V_ASSIGN expr
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
    idlist ':' direction type {
      std::list<Port*> *pl = new std::list<Port*>;

      for(std::string *name : *$1) {
        pl->push_front(new Port(name, (Direction) $3, $4));
      }

      $$ = pl;
    }
    | idlist ':' direction type V_ASSIGN expr {
      std::list<Port*> *pl = new std::list<Port*>;

      for(std::string *name : *$1) {
        pl->push_front(new Port(name, (Direction) $3, $4));
      }

      $$ = pl;
    }
    ;

type:
      ID
    | ID '(' rangelist ')'
    | ID RANGE expr TO expr
    | ID RANGE expr DOWNTO expr
    ;

rangelist:
    rangelist ',' range
    | range
    ;

range:
    expr DOWNTO expr
    | expr TO expr
    ;

idlist:
    idlist ',' ID {
        $1->push_front($3);
      }
    | ID {
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
    ARCHITECTURE ID OF ID IS arch_decls BEGN arch_body END ID ';' {
      $$ = new Arch($2, $4);
    }
    ;

arch_decls:
    arch_decls arch_decl
    | /* empty */
    ;

arch_decl:
      SIGNAL ID ':' type ';'
    |  CONSTANT ID ':' type ';'
    |  CONSTANT ID ':' type V_ASSIGN expr ';'
    ;

arch_body:
      arch_body arch_line
    | arch_line
    ;

arch_line:
      signal_assign
    | process
    ;

// Process
// Handling all the stuff for process definitions
process:
      process_name.opt PROCESS '(' sens_list ')' process_decls BEGN proc_body END PROCESS ';'
    ;

process_name.opt:
    ID ':'
    |
    ;

sens_list:
      sens_list ',' ID
    | ID
    ;

process_decls:
      process_decls process_decl
    | /* empty */
    ;

process_decl:
      SIGNAL ID ':' type ';'
    | VARIABLE ID ':' type ';'
    ;

proc_body:
      proc_body proc_line
    | /* empty */
    ;

proc_line:
    variable_assign
    | signal_assign
    | for_loop
    | if_then
    ;

signal_assign:
    name S_ASSIGN expr ';'
    | name S_ASSIGN cond_assign ';'
    ;

variable_assign:
    name V_ASSIGN expr ';'
    | name V_ASSIGN cond_assign ';'
    ;

cond_assign:
    expr WHEN expr ELSE expr
    | expr WHEN expr ELSE cond_assign
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
    | expr '=' expr
    | expr '<' expr
    | expr '>' expr
    | CHAR
    | VECT
    | name
    | LITERAL 
    | aggregate
    ;

aggregate:
    '(' aggregate_list ')'
    ;

aggregate_list:
    aggregate_list ',' aggregate_element
    | aggregate_element
    ;

aggregate_element:
    OTHERS ASSOC expr
    ;

for_loop:
    FOR ID IN range LOOP proc_body END LOOP ';'
    ;

if_then:
    IF expr THEN proc_body END IF ';'
    | IF expr THEN proc_body ELSE proc_body END IF ';'
    ;
%%

int vhdp_parse_file(FILE *file) {
  // Set Flex to read from it instead of defaulting to STDIN:
  yyin = file;

  // reset parser
  yylineno = 1;

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
