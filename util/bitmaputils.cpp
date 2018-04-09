#include <iostream>

#include "bitmaputils.hpp"

void printAsBinary(char c) {
	int mask = 0x80;
	while(mask) {
		std::cout << (c & mask ? "*" : ".");
		mask = mask >> 1;
	}
}
