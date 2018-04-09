#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>

#include "bitmaputils.hpp"

int main(int argc, char** argv) {
	char buffer[8 * 40 * 25];

	for(int i = 0; i < 8 * 40 * 25; i++) {
		buffer[i] = 0x00;
	}

	int ptr = 0;
	bool done = false;

	std::ifstream input(argv[1], std::ios::binary);
	while(!input.eof() && !done) {
		int code = input.get();
		int reps = 1;

		switch(code) {
			case 0xda:
				done = true;
				break;
			case 0x00:
			case 0x10:
			case 0xff:
			case 0xe6:
			case 0x16:
			case 0x50:
				reps = input.get();
			default:
				for(int i = 0; i < reps; i++) {
					buffer[ptr++] = code;
				}
		}
	}

	ptr = 0;

	for(int y = 0; y < 25; y++) {
		int rowPtr = ptr;
		for(int yy = 0; yy < 8; yy++) {
			int bytePtr = rowPtr;
			for(int x = 0; x < 40; x++) {
				printAsBinary(buffer[bytePtr]);
				bytePtr += 8;
			}
			std::cout << std::endl;
			rowPtr++;
		}
		ptr += 8 * 40;
	}

}