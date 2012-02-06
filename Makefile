all:
	bison -t -d MenosC.y
	flex MenosC.l
	gcc lex.yy.c MenosC.tab.c -lfl -o MenosC
	
clean:
	rm -f lex.yy.c
	rm -f MenosC.tab.c
	rm -f MenosC.tab.h
	rm -f *.o
