main: lex.yy.c parse.tab.c main.c
	gcc lex.yy.c parse.tab.c main.c -o main

lex.yy.c: lex.l parse.tab.c
	flex lex.l

parse.tab.c: parse.y
	bison -d parse.y

clean:
	rm lex.yy.c parse.tab.c parse.tab.h main