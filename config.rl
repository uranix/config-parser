#include "Lexer.h"
#include <iostream>
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
comment = '#' (^'\n')*;

main := |*
	identifier => {
		lloc->step();
		lloc->columns(te - ts);
		lval->sval = new std::string(ts, te);
		tok = Parser::token::IDENTIFIER;
		fbreak; 
	};
	number => {
		lloc->step();	
		lloc->columns(te - ts);
		lval->dval = strtod(ts, te);
		tok = Parser::token::NUMBER;
		fbreak;
	};
	comment {
		lloc->step();
		lloc->columns(te - ts);
	};
	[ ,;\t\v\f\r]+ {
		lloc->step();
		lloc->columns(te - ts); 
	};
	[\n]+ => { 
		lloc->step(); 
		lloc->lines(te - ts); 
	};
	any => {
		lloc->step();
		lloc->columns(1);
		unsigned char tc = *ts;
		tok = static_cast<Parser::token_type>(tc);
		fbreak;
	};
*|;

}%%

double Lexer::strtod(const char *p, const char *pe) {
	return atof(std::string(p, pe).c_str());
}

Lexer::Lexer(std::istream &istream, const std::string &fname) : fname(fname), istream(istream), _buf(BUFSIZE), buf(&_buf[0])
{
	p = pe = buf;
	eof = 0;

	%% write init;
}

Parser::token_type Lexer::lex(Parser::semantic_type *lval, Parser::location_type *lloc) {
	Parser::token_type tok = Parser::token::END;

	bool done = false;
	while (!done) {
		if (p == pe) {
			int space = BUFSIZE - (pe - buf);
			if (space == 0) {
				if (ts == 0) {
					space = BUFSIZE;
					p = pe = buf;
				} else {
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
		else
			lloc->step();

	}
	
	return tok;
}
