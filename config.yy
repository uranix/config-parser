%{
%}

%define namespace config
%define parser_class_name Parser
%locations
%code requires {
	namespace config { class Lexer; }
}
%code {
	#include "Lexer.h"
	static config::Parser::token_type
	yylex(config::Parser::semantic_type *yylval,
		config::Parser::location_type *yylloc,
		config::Lexer &lexer) 
	{
		return lexer.lex(yylval, yylloc);
	}
}

%union {
	double dval;
	char cval;
	const std::string *sval;
}

%token<dval> NUMBER
%token<sval> IDENTIFIER
%token<cval> CHAR
%token		END


%parse-param { config::Lexer &lexer }
%lex-param { config::Lexer &lexer }

%%

statement	: IDENTIFIER { std::cout << "id" << std::endl; }
			;

%%

void config::Parser::error(const config::location &lloc, const std::string &msg) {
	std::cerr << "Parse error at " << lloc << ": " << msg << std::endl;
}
