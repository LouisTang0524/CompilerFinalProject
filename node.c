#include "node.h"
#include <ctype.h>

/*
    char* name: 节点的名字
    int num: 子节点的数目
    ...: nd* 子节点 指针
        int 若num=0 产生epsilon的非终结符节点设为-1 终结符的节点设为行号yylineno
*/
nd *newNode(char *name, int num, ...)
{
    nd *root = malloc(sizeof(nd));
    if (!root)
    {
        printf("无法生成节点");
        exit(0);
    }

    root->name = name;
    va_list list;
    va_start(list, num);
    nodeList[nodeNum++] = root;

    if (num > 0) // 该节点还有子节点
    {
        root->intval = 0;
        nd *temp = va_arg(list, nd *);
        root->fchild = temp;
        root->line = temp->line;
        root->next = NULL;
        setChildTag(temp);

        if (num >= 2) // 有多个子节点
        {
            for (int i = 0; i < num - 1; i++)
            {
                temp->next = va_arg(list, nd *);
                temp = temp->next;
                setChildTag(temp);
            }
        }
    }
    else // 当前节点是终结符或产生空epsilon line设置为行号或-1
    {
        root->line = va_arg(list, int);
        root->fchild = NULL;
        root->next = NULL;
        if (!strcmp(root->name, "ID") || !strcmp(root->name, "TYPE"))
        {
            char *s;
            s = malloc(sizeof(char) * 40);
            strcpy(s, yytext);
            root->id_type = s;
            // root->id_type = yytext;
        }
        else if (!strcmp(root->name, "INT"))
        {
            root->intval = toInt(yytext);
        }
        else
        {
            root->fltval = atof(yytext);
        }
        root->fchild = root->next = NULL;
    }
    // printf("%s created\n", root->name);
    return root;
}

void preorder(nd *root, int level)
{
    if (root == NULL)
        return;

    if (root->line != -1) // 除了产生epsilon的非终结符之外 都需要输出信息
    {
        for (int i = 0; i < level; i++)
            printf("  ");
        printf("%s", root->name);
        // 终结符 某些需要输出值
        if (!strcmp(root->name, "ID") || !strcmp(root->name, "TYPE"))
        {
            printf(": %s\n", root->id_type);
        }
        else if (!strcmp(root->name, "INT"))
        {
            printf(": %d\n", root->intval);
        }
        else if (!strcmp(root->name, "FLOAT"))
        {
            printf(": %f\n", root->fltval);
        }
        // 非终结符 需要输出行号
        else
        {
            if (root->fchild == NULL)
                printf("\n");
            else
                printf("(%d)\n", root->line);
        }
    }

    preorder(root->fchild, level + 1);
    preorder(root->next, level);
}

void setChildTag(nd *temp)
{
    for (int i = 0; i < nodeNum; i++)
    {
        if (nodeList[i] == temp)
        {
            nodeIsChild[i] = 1;
        }
    }
}

int toInt(char *text)
{
    int len = strlen(text);
    int res = 0;
    if (len == 1 && text[0] == '0') // 十进制为0
    {
        return 0;
    }
    else // len >= 2
    {
        if (text[0] == '0')
        {
            if (text[1] == 'x' || text[1] == 'X') // 十六进制
            {
                for (char *p = text + 2; *p != '\0'; p++)
                {
                    if (isdigit(*p))
                    {
                        res = 16 * res + *p - '0';
                    }
                    else
                    {
                        char c = toupper(*p);
                        res = 16 * res + c - 'A' + 10;
                    }
                }
            }
            else // 八进制
            {
                for (char *p = text + 1; *p != '\0'; p++)
                {
                    res = 8 * res + *p - '0';
                }
            }
        }
        else // 十进制非0
        {
            res = atoi(text);
        }
    }
    return res;
}