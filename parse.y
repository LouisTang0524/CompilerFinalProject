%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(char* s);
%}

%token INT FLOAT ID TYPE SEMI COMMA
%token ASSIGNOP RELOP PLUS MINUS STAR DIV
%token AND OR DOT NOT
%token LP RP LB RB LC RC
%token STRUCT RETURN IF ELSE WHILE

%type Program ExtDefList ExtDef Specifier ExtDecList FunDec CompSt VarDec
%type StructSpecifier OptTag DefList Tag VarList ParamDec StmtList Stmt Exp
%type Def DecList Dec Args

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
Program: ExtDefList { printf("Program: ExtDefList\n"); }
    ;
ExtDefList: ExtDef ExtDefList { printf("ExtDefList: ExtDef ExtDefList\n"); }
    | {}
    ;
ExtDef: Specifier ExtDecList SEMI { printf("ExtDef: Specifier ExtDecList SEMI\n"); } /* global variable definition */
    | Specifier SEMI { printf("ExtDef: Specifier SEMI\n"); } /* struct definition */
    | Specifier FunDec CompSt { printf("ExtDef: Specifier FunDec CompSt\n"); } /* function definition */
    ;
ExtDecList: VarDec { printf("ExtDecList: VarDec\n"); }
    | VarDec COMMA ExtDecList { printf("ExtDecList: VarDec COMMA ExtDecList\n"); }
    ;
/* specifiers */
Specifier: TYPE { printf("Specifier: TYPE\n"); }
    | StructSpecifier { printf("Specifier: StructSpecifier\n"); } /* struct type */
    ;
StructSpecifier: STRUCT OptTag LC DefList RC { printf("StructSpecifier: STRUCT OptTag LC DefList RC\n"); }
    | STRUCT Tag { printf("StructSpecifier: STRUCT Tag\n"); }
    ;
OptTag: ID {printf("OptTag: ID\n"); }
    | {}
    ;
Tag: ID { printf("Tag: ID\n"); }
    ;

/* declarators */
VarDec: ID { printf("VarDec: ID\n"); }
    | VarDec LB INT RB { printf("VarDec: VarDec LB INT RB\n"); }
    ;
FunDec: ID LP VarList RP { printf("FunDec: ID LP VarList RP\n"); }
    | ID LP RP { printf("FunDec: ID LP RP\n"); }
    ;
VarList: ParamDec COMMA VarList { printf("VarList: ParamDec COMMA VarList\n"); }
    | ParamDec { printf("VarList: ParamDec\n"); }
    ;
ParamDec: Specifier VarDec { printf("ParamDec: Specifier VarDec\n"); }
    ;

/* statements */
CompSt: LC DefList StmtList RC { printf("CompSt: LC DefList StmtList RC\n"); } /* statement block, definitions must be at the beginning */
    ;
StmtList: Stmt StmtList { printf("StmtList: Stmt StmtList\n"); }
    | {}
    ;
Stmt: Exp SEMI { printf("Stmt: Exp SEMI\n"); }
    | CompSt { printf("Stmt: CompSt\n"); }
    | RETURN Exp SEMI { printf("Stmt: RETURN Exp SEMI\n"); }
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { printf("Stmt: IF LP Exp RP Stmt\n"); }
    | IF LP Exp RP Stmt ELSE Stmt { printf("Stmt: IF LP Exp RP Stmt ELSE Stmt\n"); }
    | WHILE LP Exp RP Stmt { printf("Stmt: WHILE LP Exp RP Stmt\n"); }
    ;

/* local definitions */
DefList: Def DefList { printf("DefList: Def DefList\n"); }
    | {}
    ;
Def: Specifier DecList SEMI { printf("Def: Specifier DecList SEMI\n"); }
    ;
DecList: Dec { printf("DecList: Dec\n"); }
    | Dec COMMA DecList { printf("DecList: Dec COMMA DecList\n"); }
    ;
Dec: VarDec { printf("Dec: VarDec\n"); }
    | VarDec ASSIGNOP Exp { printf("Dec: VarDec ASSIGNOP Exp\n"); }
    ;

/* expressions */
Exp: Exp ASSIGNOP Exp { printf("Exp: Exp ASSIGNOP Exp\n"); }
    | Exp AND Exp { printf("Exp: Exp AND Exp\n"); }
    | Exp OR Exp { printf("Exp: Exp OR Exp\n"); }
    | Exp RELOP Exp { printf("Exp: Exp RELOP Exp\n"); }
    | Exp PLUS Exp { printf("Exp: Exp PLUS Exp\n"); }
    | Exp MINUS Exp { printf("Exp: Exp MINUS Exp\n"); }
    | Exp STAR Exp { printf("Exp: Exp STAR Exp\n"); }
    | Exp DIV Exp { printf("Exp: Exp DIV Exp\n"); }
    | LP Exp RP { printf("Exp: LP Exp RP\n"); }
    | MINUS Exp { printf("Exp: MINUS Exp\n"); }
    | NOT Exp { printf("Exp: NOT Exp\n"); }
    | ID LP Args RP { printf("Exp: ID LP Args RP\n"); }
    | ID LP RP { printf("Exp: ID LP RP\n"); }
    | Exp LB Exp RB { printf("Exp: Exp LB Exp RB\n"); }
    | Exp DOT ID { printf("Exp: DOT ID\n"); }
    | ID { printf("Exp: ID\n"); }
    | INT { printf("Exp: INT\n"); }
    | FLOAT { printf("Exp: FLOAT\n"); }
    ;
Args: Exp COMMA Args { printf("Args: Exp COMMA Args\n"); }
    | Exp { printf("Args: Exp\n"); }
    ;

%%

void yyerror(char* s)
{
    fprintf(stderr, "%s", s);
}

int main(int argc, char** argv)
{
    yyparse();
    return 0;
}