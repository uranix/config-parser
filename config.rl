#include "Lexer.h"
#include <iostream>
#include <cstdlib>
#include <cstring>

using namespace config;

%%{

machine Lexer;
alphtype char;
write data;

D = digit;
L = alpha;
S = '+' | '-';
E = [Ee] S? D+;

identifier = L(L|D)*;
number = S? (D+ | D+ '.' D* | D* '.' D+) E?;
comment = '#' (^'\n')* '\n';

main := |*
	identifier => {
		std::cout << "I: " << std::string(ts, te) << std::endl;
		tok = Parser::token::IDENTIFIER;
		fbreak; 
	};
	number => {
		std::cout << "N: " << atof(std::string(ts, te).c_str()) << std::endl;
		tok = Parser::token::NUMBER;
		fbreak;
	};
	comment;
	space;
	any => {
		std::cout << "C: " << ts[0] << std::endl;
		tok = Parser::token::CHAR;
		fbreak;
	};
*|;

}%%

Lexer::Lexer(std::istream &istream) : istream(istream)
{
	p = pe = buf;
	eof = 0;

	%% write init;
}

void Lexer::fancy_debug() {
	std::cerr << "buf:[";
	for (int i = 0; i < BUFSIZE; i++)
		if (isprint(buf[i]))
			std::cerr << buf[i];
		else
			std::cerr << '.';
	std::cerr << "]\n";

	std::cerr << "p  : ";
	for (int i = 0; i < p - buf; i++)
		std::cerr << ' ';
	std::cerr << "^\n";

	std::cerr << "pe : ";
	for (int i = 0; i < pe - buf; i++)
		std::cerr << ' ';
	std::cerr << "^\n";

	std::cerr << "ts : ";
	if (ts) {
		for (int i = 0; i < ts - buf; i++)
			std::cerr << ' ';
		std::cerr << "^";
	} else 
		std::cerr << "null";
	std::cerr << "\n";

	std::cerr << "te : ";
	if (ts) {
		for (int i = 0; i < te - buf; i++)
			std::cerr << ' ';
		std::cerr << "^";
	} else 
		std::cerr << "null";
	std::cerr << std::endl;
}

Parser::token_type Lexer::lex(Parser::semantic_type *yylval, Parser::location_type *yylloc) {
	Parser::token_type tok = Parser::token::END;

	bool done = false;
	while (!done) {
		if (p == pe) {
			int space = BUFSIZE - (pe - buf);
			if (space == 0) {
				/* Check if we can free some space */
				if (ts == 0) {
					/* Nothing to preserve */
					space = BUFSIZE;
					p = pe = buf;
				} else {
					/* Move [ts, pe) to [buf, *) */
					int preserve = pe - ts;
					memmove(buf, ts, preserve);
					pe = p = buf + preserve;
					te = buf + (te - ts);
					ts = buf;
					space = BUFSIZE - preserve;
				}
				if (space == 0) {
					std::cerr << "Internal buffer was overflowed. Input token was too long" << std::endl;
					exit(1);
				}
			}

			istream.read(pe, space);
			int len = istream.gcount();
			if (len == 0) {
				eof = pe;
				done = true;
			}

			pe += len;
		}
		
		%% write exec;

		if (cs == Lexer_error) {
			std::cerr << "Lexer failed before finding a token" << std::endl;
			exit(1);
		}

		if (tok != Parser::token::END)
			done = true;
	}

	return tok;
}
