program=MenosC
testdir=test/
CC = g++    
CFLAGS = -lfl -ltds -DDEBUG

flex:
	flex MenosC.l

bison:
	bison -t -d MenosC.y


all: DebugMsg.cpp bison flex	
	$(CC) DebugMsg.cpp MenosC.c lex.yy.c MenosC.tab.c   -o $(program) -L./lib -I./include $(CFLAGS)
	
clean:
	rm -f lex.yy.c
	rm -f MenosC.tab.c
	rm -f MenosC.tab.h
	rm -f *.o
	rm -f $(program)
test: all
	python $(testdir)shouldcompile.py $(program)  $(testdir)

  
