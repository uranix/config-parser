#include "Lexer.h"

#include <iostream>

using namespace config;

int main() {
	Lexer lexer(std::cin);
//	Parser parser(lexer);

//	parser.parse();
	Parser::location_type lloc;
	Parser::semantic_type lval;
	Parser::token_type tok;
	while ((tok = lexer.lex(&lval, &lloc)) != Parser::token::END) {
//		std::cout << "That was tok #" << tok << std::endl;
	}
	return 0;
}
