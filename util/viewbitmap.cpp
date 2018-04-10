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

/*
 * Filters an input stream, optionally reading it as a RLE compressed
 * stream. The RLE works by reading the stream normally, but the
 * following byte values are run-length encoded, with the following
 * byte being the number of repeats (with '0x00' being read as 256):
 *
 * 		0x00, 0x10, 0x16, 0x50, 0xe6, 0xff
 *
 * In additionl the value 0xda is treated as an end-of-file marker.
 */
class StreamFilter {

private:
	std::ifstream input;
	bool compressed;

	int byte;
	int repeats;
	bool endOfCompressed;

public:
	StreamFilter(char *filename, bool compressed) : 
		input(filename, std::ios::binary), 
		compressed(compressed),
		repeats(0),
		endOfCompressed(false)
	{}

	int get() {
		while(repeats == 0) {
			byte = input.get();

			if(compressed) {
				switch(byte) {
					case 0xda:
						endOfCompressed = true;
						break;
					case 0x00:
					case 0x10:
					case 0xff:
					case 0xe6:
					case 0x16:
					case 0x50:
						repeats = input.get();
						// Treat '0' repeats as 256...
						if(repeats == 0) repeats = 256;
						break;
					default:
						repeats = 1;
				}
			} else {
				repeats = 1;
			}
		}

		--repeats;
		return byte;
	}

	bool eof() {
		return endOfCompressed || input.eof();
	}

};

/*
 * Displays a bitmap image as text on the screen. The bitmap may be read in either
 * row sequential format, or in 8x8 block format (like a C64 bitmap). In either
 * case, the image width must be given and must be a multiple of 8.
 *
 * 	filename		the name of the file containing the bitmap
 *  imageWidth		the widge of the bitmap in pixels
 *  blockFormat 	true if the image is stored as 8x8 blocks; false if the image is row sequential
 *  compressed      true if the image is RLE compressed; false otherwise
 */
void displayBitmap(char* filename, int imageWidth, bool blockFormat, bool compressed) {
	if(imageWidth % 8 != 0) {
		std::cout << "ERROR: Image width must be a multiple of 8" << std::endl;
		return;
	}

	StreamFilter input(filename, compressed);

	if(blockFormat) {
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

/*
 * Parses arguments, then passes control to displayBitmap
 */
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
		std::cout << "Usage: " << argv[0] << " [OPTIONS] FILENAME WIDTH" << std::endl;
		std::cout << std::endl;
		std::cout << "Options:" <<std::endl;
		std::cout << "  -b      The image is stored as 8x8 blocks of pixels" << std::endl;
		std::cout << "  -c      The image is compressed using RLE" << std::endl;
		exit(1);
	}

	displayBitmap(filename, width, block, compressed);

	return 0;
}