#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>
#include <vector>

#include <getopt.h>
#include <png.h>

#include "bitmaputils.hpp"

enum ArgState {
	asFilename,
	asOutFilename,
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
std::vector<char> loadBitmap(char* filename, int imageWidth, bool blockFormat, bool compressed) {
	std::vector<char> bitmap;

	if(imageWidth % 8 != 0) {
		std::cout << "ERROR: Image width must be a multiple of 8" << std::endl;
		return bitmap;
	}

	StreamFilter input(filename, compressed);

	if(blockFormat) {
		std::unique_ptr<char[]> buffer(new char[imageWidth]);

		int bytesPerRow = imageWidth / 8;

		int count = 0;
		int colPtr = 0;
		int ptr = 0;

		int byte = input.get();
		while(!input.eof()) {
			buffer[ptr] = byte;

			count++;
			if(count % imageWidth == 0) {
				// Add buffer to the bitmap
				for(int i = 0; i < imageWidth; i++) {
					bitmap.push_back(buffer[i]);
				}
				
				count = 0;
				colPtr = 0;
				ptr = colPtr;
			} else if(count % 8 == 0) {
				colPtr++;
				ptr = colPtr;
			} else {
				ptr += bytesPerRow;
			}
			byte = input.get();
		}
		std::cout << std::endl;
	} else {
		int byte = input.get();
		while(!input.eof()) {
			bitmap.push_back(byte);
			byte = input.get();
		}
	}

	return bitmap;
}

/*
 * Parses arguments, then passes control to displayBitmap
 */
int main(int argc, char** argv) {
	int width = -1;
	char* filename = NULL;
	char* outFilename = NULL;
	ArgState argState = asFilename;
	ArgState argStateBuffer = asFilename;
	bool help = false;
	bool block = false;
	bool compressed = false;

	static struct option options[] = {
		{ "help",		no_argument,		0,	'?' },
		{ "block",		no_argument,		0,	'b' },
		{ "compressed",	no_argument,		0,	'c' },
		{ "input",		required_argument,	0,	'i' },
		{ "output",		required_argument,	0,	'o' },
		{ "width",		required_argument,	0,	'w' },
	};

	int option_index = 0;

	int c;
	while((c = getopt_long(argc, argv, "bci:o:w:", options, &option_index)) != -1) {
		switch(c) {
			case 'b':
				block = true;
				break;
			case 'c':
				compressed = true;
				break;
			case 'i':
				filename = optarg;
				break;
			case 'o':
				outFilename = optarg;
				break;
			case 'w':
				width = atoi(optarg);
				break;
			case '?':
				help = true;
				break;
		}
	}

	if(help || !filename || (width <= 0)) {
		std::cout << "Usage: " << argv[0] << " [OPTIONS]" << std::endl;
		std::cout << std::endl;
		std::cout << "Options:" <<std::endl;
		std::cout << "  -b      The image is stored as 8x8 blocks of pixels" << std::endl;
		std::cout << "  -c      The image is compressed using RLE" << std::endl;
		std::cout << "  -i      Set the input filename (required)" << std::endl;
		std::cout << "  -o      Set the output filename to save in PNG format" << std::endl;
		std::cout << "  -w      Set the image width in pixels (required)" << std::endl;
		exit(1);
	}

	std::vector<char> bitmap = loadBitmap(filename, width, block, compressed);

	// Now, print the bitmap...
	int bytesPerRow = width / 8;
	int count = 0;
	for(std::vector<char>::const_iterator ptr = bitmap.begin(); ptr != bitmap.end(); ptr++) {
		printAsBinary(*ptr);
		count++;
		if(count >= bytesPerRow) {
			count = 0;
			std::cout << std::endl;
		}
	}

	std::cout << std::endl;

	int height = bitmap.size() / bytesPerRow;
	int bit_depth = 1;

	std::cout << "Image size: " << width << " x " << bitmap.size() / bytesPerRow << std::endl;

	// Save it as a PNG:
	if(outFilename) {
		// Step 4.1 - Setup

		FILE* fp = fopen(outFilename, "wb");
		png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
		png_infop info_ptr = png_create_info_struct(png_ptr);
		// setup error callbacks
		png_init_io(png_ptr, fp);

		// Step 4.2 - Write callbacks

		// Step 4.3 - Info contents

		png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, PNG_COLOR_TYPE_GRAY, 
			PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

		// Step 4.5 - Write file

		std::vector<png_bytep> row_pointers;
		png_bytep bitmapPtr = (png_bytep)(&(*(bitmap.begin())));
		for(int i = 0; i < height; i++) {
			row_pointers.push_back(bitmapPtr);
			bitmapPtr += bytesPerRow;
		}
		png_set_rows(png_ptr, info_ptr, &(*(row_pointers.begin())));

		png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

		fclose(fp);
	}
	return 0;
}