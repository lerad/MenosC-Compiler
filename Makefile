program=MenosC
testdir=test/
all:
	bison -t -d MenosC.y
	flex MenosC.l
	gcc MenosC.c lex.yy.c MenosC.tab.c  -o program -L./lib -I./include -lfl -ltds
	
clean:
	rm -f lex.yy.c
	rm -f MenosC.tab.c
	rm -f MenosC.tab.h
	rm -f *.o
	rm -f $(program)
test: all
	python $(testdir)shouldcompile.py $(program)  $(testdir)

  
