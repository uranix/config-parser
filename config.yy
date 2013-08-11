%{
%}

%define namespace config
%define parser_class_name Parser
%locations
%initial-action {
	@$.begin.filename = @$.end.filename = &lexer.fname;
}
%code requires {
	#include <vector>
	#include "Value.h"

	namespace config { class Lexer; }
}
%code {
	#include "Lexer.h"

	using namespace std;

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
	Value *value;
	Entry *statement;
	Sequence *sequence;
	Table *table;
}

%type<value> value array object config
%type<sequence> sequence
%type<table> table
%type<statement> statement 

%token<dval> NUMBER
%token<sval> IDENTIFIER
%token		END 0

%parse-param { config::Lexer &lexer}
%parse-param { Object *&config }
%lex-param { config::Lexer &lexer }

%start config
%%

value	
		: NUMBER		{ $$ = new Number($1); }
		| IDENTIFIER	{ $$ = new Identifier($1); delete $1; }
		| array			{ $$ = $1; }
		| object		{ $$ = $1; }
		;

statement
		: IDENTIFIER '=' value	{ $$ = new Entry(*$1, $3); delete $1; }
		;

table
		: statement			{ $$ = new Table(); $$->push_back($1); }
		| table statement	{ $$ = $1; $1->push_back($2); }
		;

sequence
		: value				{ $$ = new Sequence(); $$->push_back($1); }
		| sequence value	{ $$ = $1; $1->push_back($2); }
		;

object	
		: IDENTIFIER '{' '}'		{ $$ = new Object(*$1, new Table()); delete $1; }
		| IDENTIFIER '{' table '}'	{ $$ = new Object(*$1, $3); delete $1; }
		;

array	
		: '[' ']'			{ $$ = new Map(new Table()); }
		| '[' table ']'		{ $$ = new Map($2); }
		| '[' sequence ']'	{ $$ = new Vector($2); }
		;

config
		: table				{ config = new Object("Config", $1); }
		;

%%

void config::Parser::error(const config::location &lloc, const string &msg) {
	cerr << lloc << ": " << msg << endl;
}
