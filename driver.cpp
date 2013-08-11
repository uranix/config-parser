#include "Lexer.h"

#include <iostream>
#include <cassert>

using namespace config;

int main() {
	Lexer lexer(std::cin);
//	Parser parser(lexer);

//	parser.parse();
	Parser::location_type lloc;
	Parser::semantic_type lval;
	Parser::token_type tok;
	while ((tok = lexer.lex(&lval, &lloc)) != Parser::token::END) {
		switch (tok) {
			case Parser::token::IDENTIFIER:
				std::cout << lloc << ": identifier " << *lval.sval << std::endl;
			break;
			case Parser::token::NUMBER:
				std::cout << lloc << ": number " << lval.dval << std::endl;
			break;
			case Parser::token::CHAR:
				std::cout << lloc << ": symbol " << lval.cval << std::endl;
			break;
			case Parser::token::END: 
				assert(false);
		}
	}
	return 0;
}
