#include <stdio.h>
#include <stdlib.h>

#include "parse.tab.h"

int main(int argc, char **argv)
{
    if (argc < 2)
        return 1;

    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror(argv[1]);
        return 1;
    }
    yyparse();
    fclose(f);

    return 0;
}