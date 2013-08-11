BISON=bison
RAGEL=ragel
CXX=c++ -ferror-limit=5
CXXFLAGS=-g -O0 -Wall

%.tab.cc %.tab.hh : %.yy
	${BISON} -t -d -L c++ $<

%.lex.cc : %.rl
	${RAGEL} -G2 -o $@ $<

all: driver 

clean:
	rm -f *.tab.cc *.lex.cc *.hh *.o

parser: config.tab.o

lexer: config.lex.o

driver: parser lexer driver.o
	${CXX} -o $@ config.tab.o config.lex.o driver.o

config.tab.cc :: Lexer.h

config.lex.cc :: Lexer.h
