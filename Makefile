program=cmc
testdir=test/
CC = g++    
CFLAGS = -lfl -ltds -lgci -Wno-write-strings 

# For debug activate -DDEBUG in CFLAGS

all: DebugMsg.cpp bison flex	
	$(CC) DebugMsg.cpp MenosC.c lex.yy.c MenosC.tab.c  -L./lib -I./include $(CFLAGS) -o $(program) 

flex:
	flex MenosC.l

bison:
	bison -t -d MenosC.y


	
clean:
	rm -f lex.yy.c
	rm -f MenosC.tab.c
	rm -f MenosC.tab.h
	rm -f *.o
	rm -f $(program)
test: all
	python $(testdir)shouldcompile.py $(program)  $(testdir)/ExamplesPoliformat

  
