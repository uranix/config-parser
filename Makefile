BISON=bison
RAGEL=ragel
CXX=c++

%.tab.cc : %.yy
	${BISON} -d -L c++ $<

all: parser lexer

clean:
	rm -f *.tab.cc *.hh *.o

parser: config.tab.o

lexer: 
