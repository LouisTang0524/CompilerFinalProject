%option noyywrap yylineno

%{
#include <stdlib.h>
#include <stdio.h>

#include "parse.tab.h"
#include "node.h"
%}


INT_DEC 0|[1-9][0-9]*
INT_HEX 0[xX][a-fA-F0-9]+
INT_OCT 0[1-7][0-7]*
INT {INT_DEC}|{INT_HEX}|{INT_OCT}
FLOAT ({INT}"."[0-9]+)|([0-9]*"."[0-9]*[eE][-+]?[0-9]+)
INT_HEX_ERROR 0[xX][a-fA-F0-9]*[g-zG-Z]+[a-fA-F0-9]*
INT_OCT_ERROR 0[0-7]*[8-9]+[0-7]*

ID [_a-zA-Z][_a-zA-Z0-9]*
STRUCT struct
RETURN return
IF if
ELSE else
WHILE while
TYPE int|float

SEMI    ;
COMMA   ,
ASSIGNOP =
PLUS    \+
MINUS   \-
STAR    \*
DIV     \/
AND     &&
OR      \|\|
DOT     \.
NOT     \!
LP      \(
RP      \)
LB      \[
RB      \]
LC      \{
RC      \}
RELOP   >|<|<=|>=|==|!=


%%

{TYPE}      { yylval.tnode = newNode("TYPE", 0, yylineno); return TYPE; }
{STRUCT}    { yylval.tnode = newNode("STRUCT", 0, yylineno); return STRUCT; }
{RETURN}    { yylval.tnode = newNode("RETURN", 0, yylineno); return RETURN; }
{IF}        { yylval.tnode = newNode("IF", 0, yylineno); return IF; }
{ELSE}      { yylval.tnode = newNode("ELSE", 0, yylineno); return ELSE; }
{WHILE}     { yylval.tnode = newNode("WHILE", 0, yylineno); return WHILE; }

{INT_HEX_ERROR} { printf("Error type A at Line %d: hex int error.", yylineno); }
{INT_OCT_ERROR} { printf("Error type A at Line %d: oct int error.", yylineno); }
{INT}   { yylval.tnode = newNode("INT", 0, yylineno); return INT; }
{FLOAT} { yylval.tnode = newNode("FLOAT", 0, yylineno); return FLOAT; }

{SEMI}      { yylval.tnode = newNode("SEMI", 0, yylineno); return SEMI; }
{COMMA}     { yylval.tnode = newNode("COMMA", 0, yylineno); return COMMA; }
{ASSIGNOP}  { yylval.tnode = newNode("ASSIGNOP", 0, yylineno); return ASSIGNOP; }
{PLUS}      { yylval.tnode = newNode("PLUS", 0, yylineno); return PLUS; }
{MINUS}     { yylval.tnode = newNode("MINUS", 0, yylineno); return MINUS; }
{STAR}      { yylval.tnode = newNode("STAR", 0, yylineno); return STAR; }
{DIV}       { yylval.tnode = newNode("DIV", 0, yylineno); return DIV; }
{AND}       { yylval.tnode = newNode("AND", 0, yylineno); return AND; }
{OR}        { yylval.tnode = newNode("OR", 0, yylineno); return OR; }
{DOT}       { yylval.tnode = newNode("DOT", 0, yylineno); return DOT; }
{NOT}       { yylval.tnode = newNode("NOT", 0, yylineno); return NOT; }
{LP}        { yylval.tnode = newNode("LP", 0, yylineno); return LP; }
{RP}        { yylval.tnode = newNode("RP", 0, yylineno); return RP; }
{LB}        { yylval.tnode = newNode("LB", 0, yylineno); return LB; }
{RB}        { yylval.tnode = newNode("RB", 0, yylineno); return RB; }
{LC}        { yylval.tnode = newNode("LC", 0, yylineno); return LC; }
{RC}        { yylval.tnode = newNode("RC", 0, yylineno); return RC; }
{RELOP}     { yylval.tnode = newNode("RELOP", 0, yylineno); return RELOP; }
{ID}        { yylval.tnode = newNode("ID", 0, yylineno); return ID; }

[ \f\v\s\t\r\n] {}

. {
    printf("Error type A at Line %d: Mystirious character '%s'.\n", yylineno, yytext);
}

%%