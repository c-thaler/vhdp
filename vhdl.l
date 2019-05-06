%{
/***** C Stuff *****/
#include <stdio.h>
#include <string>
#include <list>

#include "bison.tab.hpp"

int linenum = 1;

void showError();
%}
%option noyywrap
%option yylineno

/***** RegEx *****/
comment  (--[^\n]*)
literal  ([0-9])+
name     ([a-zA-Z_]){1}([a-zA-Z0-9_])*
space    ([ \t])+
char     (\'[01-x]\')
vect     (\"[01-x]*\")

/***** Token specification *****/
%%
"architecture"   {return ARCHITECTURE;}
"entity"         {return ENTITY;}
"process"        {return PROCESS;}
"begin"          {return BEGN;}
"end"            {return END;}
"is"             {return IS;}
"of"             {return OF;}
"port"           {return PORT;}
"generic"        {return GENERIC;}
"in"             {return IN;}
"out"            {return OUT;}
"inout"          {return INOUT;}
"library"        {return LIBRARY;}
"use"            {return USE;}
"for"            {return FOR;}
"if"             {return IF;}
"then"           {return THEN;}
"loop"           {return LOOP;}
"to"             {return TO;}
"downto"         {return DOWNTO;}
"signal"         {return SIGNAL;}
"variable"       {return VARIABLE;}
"and"            {return AND;}
"or"             {return OR;}
"xor"            {return XOR;}
"others"         {return OTHERS;}
"range"          {return RANGE;}
"<="             {return S_ASSIGN;}
":="             {return V_ASSIGN;}
"=>"             {return ASSOC;}
{literal}        {return LITERAL;}
{name}           {yylval.str = new std::string(yytext); return NAME;}
{char}           {return CHAR;}
{vect}           {return VECT;}
"&"              {return '&';}
"="              {return '=';}
"<"              {return '<';}
">"              {return '>';}
"+"              {return '+';}
"-"              {return '-';}
"*"              {return '*';}
"/"              {return '/';}
";"              {return ';';}
"."              {return '.';}
","              {return ',';}
":"              {return ':';}
"("              {return '(';}
")"              {return ')';}
"\""             {return '\"';}
"\'"             {return '\'';}
{space}          ;
{comment}        ;
\n               {++linenum;}
.                {showError();}
%%

/***** C Functions *****/
void showError() {
    printf("An error has occured in line %d!\n", linenum);
}