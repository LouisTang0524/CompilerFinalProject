%option noyywrap yylineno

%{
#include <stdlib.h>
#include <stdio.h>

#include "parse.tab.h"
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

{TYPE} { return TYPE; }
{STRUCT} { return STRUCT; }
{RETURN} { return RETURN; }
{IF} { return IF; }
{ELSE} { return ELSE; }
{WHILE} { return WHILE; }

{INT_HEX_ERROR} { printf("Error type A at Line %d: hex int error.", yylineno); }
{INT_OCT_ERROR} { printf("Error type A at Line %d: oct int error.", yylineno); }
{INT} { return INT; }
{FLOAT} { return FLOAT; }

{SEMI} { return SEMI; }
{COMMA} { return COMMA; }
{ASSIGNOP} { return ASSIGNOP; }
{PLUS} { return PLUS; }
{MINUS} { return MINUS; }
{STAR} { return STAR; }
{DIV} { return DIV; }
{AND} { return AND; }
{OR} { return OR; }
{DOT} { return DOT; }
{NOT} { return NOT; }
{LP} { return LP; }
{RP} { return RP; }
{LB} { return LB; }
{RB} { return RB; }
{LC} { return LC; }
{RC} { return RC; }
{RELOP} { return RELOP; }
{ID} { return ID; }

[ \f\v\s\t\r\n] {}

. {
    printf("Error type A at Line %d: Mystirious character '%s'.\n", yylineno, yytext);
}

%%