#ifndef __CONFIG__LEXER_H__
#define __CONFIG__LEXER_H__

#include "config.tab.hh"
#include <istream>

namespace config {

class Lexer {
public:
	Lexer(std::istream &stream);
	Parser::token_type lex(Parser::semantic_type *yylval,
		Parser::location_type *yylloc);
private:
	void fancy_debug();
	std::istream &istream;
	static const int BUFSIZE = 64;
	char buf[BUFSIZE];
	char *p;
	char *pe;
	char *eof;
	char *ts;
	char *te;
	int cs, act;
};

}

#endif
