BISON=bison
RAGEL=ragel
CXX=clang++ -ferror-limit=5
CXXFLAGS=-g -O2 -Wall

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

config.tab.o :: config.yy Lexer.h config.tab.hh Value.h
config.lex.o :: config.rl config.yy Lexer.h config.tab.hh Value.h
config.tab.o :: config.yy Lexer.h config.tab.hh Value.h
