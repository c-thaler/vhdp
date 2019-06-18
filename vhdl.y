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
%token GENERIC MAP
%token <pl> PORT
%token <n> IN OUT INOUT
%token SIGNAL VARIABLE CONSTANT
%token XOR AND OR NOT CONCAT
%token S_ASSIGN V_ASSIGN ASSOC
%token OTHERS RANGE
%token PURE FUNCTION RETURN

%token <str> ID
%token LITERAL CHAR VECT

%left AND OR XOR
%left '=' '<' '>'
%left '+' '-'
%left '*' '/'
%left '&'
%left TO DOWNTO

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
    ID '(' expr_list ')'
    ;

expr_list:
      expr_list ',' expr
    | expr
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
    | ID '(' expr_list ')'
    | ID RANGE expr
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

direction.opt:
    direction
    |
    ;

architecture:
    ARCHITECTURE ID OF ID IS arch_decls BEGN arch_body arch_end ';' {
      $$ = new Arch($2, $4);
    }
    ;

arch_end:
    END ARCHITECTURE ID
    | END ARCHITECTURE
    | END ID
    | END
    ;

arch_decls:
    arch_decls arch_decl
    | /* empty */
    ;

arch_decl:
      SIGNAL ID ':' type ';'
    | CONSTANT ID ':' type ';'
    | CONSTANT ID ':' type V_ASSIGN expr ';'
    | function
    ;

arch_body:
      arch_body arch_line
    | arch_line
    ;

arch_line:
      signal_assign
    | process
    | instantiation
    ;

// Function
// Handle all the function declaration and definition stuff
// We allow all statements from processes for functions. Maybe that is not
// really allowed by VHDL syntax.
function:
      function_pure.opt FUNCTION ID '(' function_params ')' RETURN type IS function_decls BEGN proc_body function_end ';'

function_pure.opt:
    PURE
    |
    ;

function_end:
    END FUNCTION ID
    | END FUNCTION
    | END ID
    | END
    ;

function_params:
      function_params ';' function_param
    | function_param
    ;

function_param:
      idlist ':' direction.opt type
    | idlist ':' direction.opt type V_ASSIGN expr 
    ;

function_decls:
    function_decls function_decl
    | /* empty */
    ;

function_decl:
      VARIABLE ID ':' type ';'
    | CONSTANT ID ':' type ';'
    | CONSTANT ID ':' type V_ASSIGN expr ';'
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
    | return
    ;

instantiation:
    ID ':' ENTITY ID mappings ';'
    ;

mappings:
    mappings port_map
    | mappings generic_map
    | port_map
    | generic_map
    ;

port_map:
    PORT MAP '(' maplist ')'

generic_map:
    GENERIC MAP '(' maplist ')'
    ;

maplist:
    maplist ',' association
    | association
    ;

association:
    ID ASSOC ID

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
    | '-' expr
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
    | expr TO expr
    | expr DOWNTO expr
    | name '\'' name
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
    FOR ID IN expr LOOP proc_body END LOOP ';'
    ;

if_then:
    IF expr THEN proc_body END IF ';'
    | IF expr THEN proc_body ELSE proc_body END IF ';'
    ;

return:
    RETURN expr ';'
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
