#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>

#include "bitmaputils.hpp"

int main(int argc, char** argv) {
	char buffer[21 * 3];

	for(int i = 0; i < 21 * 3; i++) {
		buffer[i] = 0x00;
	}

	std::ifstream input(argv[1], std::ios::binary);
	input.read(buffer, 21 * 3);

	for(int i = 0; i < 63; i++) {
		printAsBinary(buffer[i]);

		if(i % 3 == 2) {
			std::cout << std::endl;
		}
	}
}