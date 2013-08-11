%{
%}

%define namespace config
%define parser_class_name Parser
%locations
%initial-action {
	@$.begin.filename = @$.end.filename = &lexer.fname;
}
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
	const std::string *sval;
}

%token<dval> NUMBER
%token<sval> IDENTIFIER
%token		END


%parse-param { config::Lexer &lexer }
%lex-param { config::Lexer &lexer }

%start config
%%

value	
		: NUMBER
		| IDENTIFIER
		| array
		| object
		;

statement
		: IDENTIFIER '=' value
		;

table
		: statement
		| table statement
		;

sequence
		: value
		| sequence value
		;

object	
		: IDENTIFIER '{' '}'
		| IDENTIFIER '{' table '}'
		;

array	: '[' ']'
		| '[' table ']'
		| '[' sequence ']'
		;

config	
		: table
		;

%%

void config::Parser::error(const config::location &lloc, const std::string &msg) {
	std::cerr << "Parse error at " << lloc << ": " << msg << std::endl;
}
