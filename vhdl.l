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
comment   (--[^\n]*)
literal   ([0-9])+
id        ([a-zA-Z_]){1}([a-zA-Z0-9_\.])*
attribute (\'([a-zA-Z])*)
space     ([ \t])+
char      (\'[01-x]\')
vect      (\"[01-x]*\")

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
"map"            {return MAP;}
"in"             {return IN;}
"out"            {return OUT;}
"inout"          {return INOUT;}
"library"        {return LIBRARY;}
"use"            {return USE;}
"for"            {return FOR;}
"if"             {return IF;}
"else"           {return ELSE;}
"then"           {return THEN;}
"when"           {return WHEN;}
"loop"           {return LOOP;}
"to"             {return TO;}
"downto"         {return DOWNTO;}
"signal"         {return SIGNAL;}
"variable"       {return VARIABLE;}
"constant"       {return CONSTANT;}
"pure"           {return PURE;}
"function"       {return FUNCTION;}
"return"         {return RETURN;}
"not"            {return NOT;}
"and"            {return AND;}
"or"             {return OR;}
"xor"            {return XOR;}
"others"         {return OTHERS;}
"range"          {return RANGE;}
"<="             {return S_ASSIGN;}
":="             {return V_ASSIGN;}
"=>"             {return ASSOC;}
{literal}        {return LITERAL;}
{id}             {yylval.str = new std::string(yytext); return ID;}
{char}           {return CHAR;}
{vect}           {return VECT;}
{attribute}      {return ATTRIBUTE;}
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
{space}          ;
{comment}        ;
\n               {++linenum;}
.                {showError();}
%%

/***** C Functions *****/
void showError() {
    printf("An error has occured in line %d!\n", linenum);
}
