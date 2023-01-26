main: lex.yy.c parse.tab.c node.c
	gcc lex.yy.c parse.tab.c node.c -g -o main

lex.yy.c: lex.l parse.tab.c
	flex lex.l

parse.tab.c: parse.y
	bison -d parse.y

clean:
	rm lex.yy.c parse.tab.c parse.tab.h main