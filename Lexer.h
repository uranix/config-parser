#ifndef __CONFIG__LEXER_H__
#define __CONFIG__LEXER_H__

#include "config.tab.hh"

namespace config {
	class Lexer {
		public:
		config::Parser::token_type lex(config::Parser::semantic_type *yylval,
			config::Parser::location_type *yylloc);
	};
}

#endif
