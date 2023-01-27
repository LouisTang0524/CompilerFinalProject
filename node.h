#ifndef __NODE_H
#define __NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern char *yytext;
extern int yylineno;

typedef struct node
{
    char *name;
    int line;
    struct node *fchild, *next;
    union
    {
        int intval;
        float fltval;
        char *id_type;
    };
} nd;

int nodeNum;
nd *nodeList[5000];
int nodeIsChild[5000];

int hasFault;

nd *newNode(char *name, int num, ...);
void preorder(nd *root, int level);
void setChildTag(nd *temp);

int toInt(char *text);

#endif // __NODE_H