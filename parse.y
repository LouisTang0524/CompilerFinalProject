%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"
int yylex();
void yyerror(char* s);
%}

%union {
    struct node* tnode;
}

%token<tnode> INT FLOAT ID TYPE SEMI COMMA
%token<tnode> ASSIGNOP RELOP PLUS MINUS STAR DIV
%token<tnode> AND OR DOT NOT
%token<tnode> LP RP LB RB LC RC
%token<tnode> STRUCT RETURN IF ELSE WHILE

%type<tnode> Program ExtDefList ExtDef Specifier ExtDecList FunDec CompSt VarDec
%type<tnode> StructSpecifier OptTag DefList Tag VarList ParamDec StmtList Stmt Exp
%type<tnode> Def DecList Dec Args

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left LP RP LB RB LC RC DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%% /* rules */

/* high-level definitions */
Program: ExtDefList { $$ = newNode("Program", 1, $1); }
    ;
ExtDefList: ExtDef ExtDefList   { $$ = newNode("ExtDefList", 2, $1, $2); }
    |                           { $$ = newNode("ExtDefList", 0, -1); }
    ;
ExtDef: Specifier ExtDecList SEMI       { $$ = newNode("ExtDef", 3, $1, $2, $3); } /* global variable definition */
    | Specifier ExtDecList error SEMI   { printf("Missing \';\'\n"); }
    | Specifier SEMI                    { $$ = newNode("ExtDef", 2, $1, $2); } /* struct definition */
    | Specifier error SEMI              { printf("Missing \';\'\n"); }
    | Specifier FunDec CompSt           { $$ = newNode("ExtDef", 3, $1, $2, $3); } /* function definition */
    ;
ExtDecList: VarDec                  { $$ = newNode("ExtDefList", 1, $1); }
    | VarDec COMMA ExtDecList       { $$ = newNode("ExtDecList", 3, $1, $2, $3); }
    ;
/* specifiers */
Specifier: TYPE         { $$ = newNode("Specifier", 1, $1); }
    | StructSpecifier   { $$ = newNode("Specifier", 1, $1); } /* struct type */
    ;
StructSpecifier: STRUCT OptTag LC DefList RC    { $$ = newNode("StructSpecifier", 5, $1, $2, $3, $4, $5); }
    | STRUCT OptTag LC DefList error RC         { printf("1Missing \'}\'\n");}
    | STRUCT Tag                                { $$ = newNode("StructSpecifier", 2, $1, $2); }
    ;
OptTag: ID  { $$ = newNode("OptTag", 1, $1); }
    |       { $$ = newNode("OptTag", 0, -1); }
    ;
Tag: ID { $$ = newNode("Tag", 1, $1); }
    ;

/* declarators */
VarDec: ID                      { $$ = newNode("VarDec", 1, $1); }
    | VarDec LB INT RB          { $$ = newNode("VarDec", 4, $1, $2, $3, $4); }
    | VarDec LB INT error RB    { printf("Missing \']\'\n"); }
    ;
FunDec: ID LP VarList RP        { $$ = newNode("FunDec", 4, $1, $2, $3, $4); }
    | ID LP VarList error RP    { printf("Missing \')\'\n"); }
    | ID LP RP                  { $$ = newNode("FunDec", 3, $1, $2, $3); }
    | ID LP error RP            { printf("Missing \')\'\n"); }
    ;
VarList: ParamDec COMMA VarList { $$ = newNode("VarList", 3, $1, $2, $3); }
    | ParamDec                  { $$ = newNode("VarList", 1, $1); }
    ;
ParamDec: Specifier VarDec { $$ = newNode("ParamDec", 2, $1, $2); }
    ;

/* statements */
CompSt: LC DefList StmtList RC      { $$ = newNode("CompSt", 4, $1, $2, $3, $4); } /* statement block, definitions must be at the beginning */
    | LC DefList StmtList error RC  { printf("2Missing \'}\'\n"); }
    ;
StmtList: Stmt StmtList { $$ = newNode("StmtList", 2, $1, $2); }
    |                   { $$ = newNode("StmtList", 0, -1); }
    ;
Stmt: Exp SEMI                                      { $$ = newNode("Stmt", 2, $1, $2); }
    | Exp error SEMI                                { printf("Missing \';\'\n"); }
    | CompSt                                        { $$ = newNode("Stmt", 1, $1); }
    | RETURN Exp SEMI                               { $$ = newNode("Stmt", 3, $1, $2, $3); }
    | RETURN Exp error SEMI                         { printf("Missing \';\'\n"); }
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE       { $$ = newNode("Stmt", 5, $1, $2, $3, $4, $5); }
    | IF LP Exp error RP Stmt %prec LOWER_THAN_ELSE { printf("Missing \')\'\n"); }
    | IF LP Exp RP Stmt ELSE Stmt                   { $$ = newNode("Stmt", 7, $1, $2, $3, $4, $5, $6, $7); }
    | IF LP Exp error RP Stmt ELSE Stmt             { printf("Missing \')\'\n"); }
    | WHILE LP Exp RP Stmt                          { $$ = newNode("Stmt", 5, $1, $2, $3, $4, $5); }
    | WHILE LP Exp error RP Stmt                    { printf("Missing \')\'\n"); }
    ;

/* local definitions */
DefList: Def DefList    { $$ = newNode("DefList", 2, $1, $2); }
    |                   { $$ = newNode("DefList", 0, -1); }
    ;
Def: Specifier DecList SEMI         { $$ = newNode("Def", 3, $1, $2, $3); }
    | Specifier DecList error SEMI  { printf("Missing \';\'\n"); }
    ;
DecList: Dec            { $$ = newNode("DecList", 1, $1); }
    | Dec COMMA DecList { $$ = newNode("DecList", 3, $1, $2, $3); }
    ;
Dec: VarDec                 { $$ = newNode("Dec", 1, $1); }
    | VarDec ASSIGNOP Exp   { $$ = newNode("Dec", 3, $1, $2, $3); }
    ;

/* expressions */
Exp: Exp ASSIGNOP Exp       { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp AND Exp           { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp OR Exp            { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp RELOP Exp         { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp PLUS Exp          { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp MINUS Exp         { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp STAR Exp          { $$ = newNode("Exp", 3, $1, $2, $3); }
    | Exp DIV Exp           { $$ = newNode("Exp", 3, $1, $2, $3); }
    | LP Exp RP             { $$ = newNode("Exp", 3, $1, $2, $3); }
    | LP Exp error RP       { printf("Missing \')\'\n"); }
    | MINUS Exp             { $$ = newNode("Exp", 2, $1, $2); }
    | NOT Exp               { $$ = newNode("Exp", 2, $1, $2); }
    | ID LP Args RP         { $$ = newNode("Exp", 4, $1, $2, $3, $4); }
    | ID LP Args error RP   { printf("Missing \')\'\n"); }
    | ID LP RP              { $$ = newNode("Exp", 3, $1, $2, $3); }
    | ID LP error RP        { printf("Missing \')\'\n"); }
    | Exp LB Exp RB         { $$ = newNode("Exp", 4, $1, $2, $3, $4); }
    | Exp LB Exp error RB   { printf("Missing \']\'\n"); }
    | Exp DOT ID            { $$ = newNode("Exp", 3, $1, $2, $3); }
    | ID                    { $$ = newNode("Exp", 1, $1); }
    | INT                   { $$ = newNode("Exp", 1, $1); }
    | FLOAT                 { $$ = newNode("Exp", 1, $1); }
    ;
Args: Exp COMMA Args    { $$ = newNode("Args", 3, $1, $2, $3); }
    | Exp               { $$ = newNode("Args", 1, $1); }
    ;

%%

void yyerror(char* s)
{
    hasFault = 1;
    fprintf(stderr, "Error type B at Line %d: %s.", yylineno, s);
}

int main(int argc, char** argv)
{
    printf("start\n");
    hasFault = 0;
    nodeNum = 0;
    memset(nodeList, 0, sizeof(nd*) * 5000);
    memset(nodeIsChild, 0, sizeof(int) * 5000);
    yyparse();
    if (hasFault) printf("error encountered\n");
    else
    {
        for (int i = 0; i < nodeNum; i++)
        {
            if (nodeIsChild[i])
                continue;
            else
            {
                preorder(nodeList[i], 0);
                break;
            }
        }
    }
    
    printf("finish\n");
    return 0;
}