#ifndef __CONFIG__LEXER_H__
#define __CONFIG__LEXER_H__

#include "config.tab.hh"
#include <istream>
#include <vector>
#include <string>

namespace config {

class Lexer {
public:
	Lexer(std::istream &stream);
	Parser::token_type lex(Parser::semantic_type *yylval,
		Parser::location_type *yylloc);
private:
	const std::string *strdup(const char *p, const char *pe);
	double strtod(const char *p, const char *pe);
	std::istream &istream;
	static const int BUFSIZE = 65536;
	int bufstart;
	std::vector<char> _buf;
	std::vector<std::string> strings;
	char * const buf;
	char *p;
	char *pe;
	char *eof;
	char *ts;
	char *te;
	int cs, act;
};

}

#endif
