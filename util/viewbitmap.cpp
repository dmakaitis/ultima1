#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>

#include "bitmaputils.hpp"

enum ArgState {
	asFilename,
	asWidth,
	asDone
};

void displayBitmap(char* filename, int imageWidth, bool blockFormat, bool compressed) {
	std::ifstream input(filename, std::ios::binary);

	if(blockFormat) {
		if(compressed) {
			std::cout << "filename: " << filename << std::endl;
			std::cout << "width: " << imageWidth << std::endl;
			std::cout << "block: " << blockFormat << std::endl;
			std::cout << "compressed: " << compressed << std::endl;
		} else {
			if(imageWidth % 8 != 0) {
				std::cout << "ERROR: Image width must be a multiple of 8" << std::endl;
				return;
			}

			int blocksPerRow = imageWidth / 8;
			std::unique_ptr<char[]> buffer(new char[imageWidth]);

			int colPtr = 0;
			int ptr = 0;
			int count = 0;

			int byte = input.get();
			while(!input.eof()) {
				buffer[ptr] = byte;

				count++;
				if(count % imageWidth == 0) {
					// Print 8 rows...
					ptr = 0;
					for(int row = 0; row < 8; row++) {
						for(int col = 0; col < blocksPerRow; col++) {
							printAsBinary(buffer[ptr++]);
						}
						std::cout << std::endl;
					}
					
					count = 0;
					colPtr = 0;
					ptr = colPtr;
				} else if(count % 8 == 0) {
					colPtr++;
					ptr = colPtr;
				} else {
					ptr += blocksPerRow;
				}
				byte = input.get();
			}
			std::cout << std::endl;
		}
	} else {
		int x = 0;
		int byte = input.get();
		while(!input.eof()) {
			printAsBinary(byte);

			x += 8;
			if(x >= imageWidth) {
				x = 0;
				std::cout << std::endl;
			}

			byte = input.get();
		}
		std::cout << std::endl;
	}
}

int main(int argc, char** argv) {
	int width = -1;
	char* filename = NULL;
	ArgState argState = asFilename;
	bool help = false;
	bool block = false;
	bool compressed = false;

	for(int i = 1; i < argc; i++) {
		char* arg = argv[i];
		if(*arg == '-') {
			for(int j = 1; arg[j]; j++) {
				switch(arg[j]) {
					case '?':
						help = true;
						break;
					case 'b':
						block = true;
						break;
					case 'c':
						compressed = true;
						break;
				}
			}
		} else {
			switch(argState) {
				case asFilename:
					filename = argv[i];
					argState = asWidth;
					break;
				case asWidth:
					width = atoi(argv[i]);
					argState = asDone;
					break;
				default:
					help = true;
					argState = asDone;
					break;
			}
		}
	}

	if(help || !filename || (width <= 0)) {
		std::cout << "Usage: " << argv[0] << " [-b] [filename] [width]" << std::endl;
		exit(1);
	}

	displayBitmap(filename, width, block, compressed);

	exit(0);

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

	return 0;
}