#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>

#include "bitmaputils.hpp"

const int bytesPerChar = 8;
const int charsPerRow = 16;

void printBuffer(char* buffer) {
	int ptr = 0;

	for(int y = 0; y < bytesPerChar; y++) {
		for(int x = 0; x < charsPerRow; x++) {
			printAsBinary(buffer[ptr++]);
			std::cout << " ";
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

int main(int argc, char** argv) {
	char buffer[bytesPerChar * charsPerRow];

	for(int i = 0; i < bytesPerChar * charsPerRow; i++) {
		buffer[i] = 0x00;
	}

	int count = 0;
	int ptr = 0;
	int colptr = 0;

	std::ifstream input(argv[1], std::ios::binary);
	while(!input.eof()) {
		buffer[ptr] = input.get();

		count++;
		
		if(count % (bytesPerChar * charsPerRow) == 0) {
			printBuffer(buffer);
			count = 0;
			ptr = 0;
			colptr = 0;
		} else {
			if(count % bytesPerChar == 0) {
				colptr++;
				ptr = colptr;
			} else {
				ptr += charsPerRow;
			}
		}
	}

}