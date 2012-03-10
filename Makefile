program=MenosC
testdir=test/
CC = g++    
CFLAGS = -lfl -ltds

flex:
	flex MenosC.l

bison:
	bison -t -d MenosC.y


all: bison flex	
	$(CC) MenosC.c lex.yy.c MenosC.tab.c  -o $(program) -L./lib -I./include $(CFLAGS)
	
clean:
	rm -f lex.yy.c
	rm -f MenosC.tab.c
	rm -f MenosC.tab.h
	rm -f *.o
	rm -f $(program)
test: all
	python $(testdir)shouldcompile.py $(program)  $(testdir)

  
