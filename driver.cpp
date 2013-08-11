#include "Lexer.h"

#include <iostream>
#include <fstream>
#include <cassert>

using namespace config;

int main(int argc, char **argv) {
	if (argc < 2) {
		std::cerr << "USAGE: driver <config file>" << std::endl;
		return 1;
	}
	std::fstream f(argv[1], std::ios::in);
	Lexer lexer(f, argv[1]);

	Object *config;
	Parser parser(lexer, config);

	if (parser.parse())
		return 1;
	config->print(std::cout);
	delete config;

	return 0;
}
