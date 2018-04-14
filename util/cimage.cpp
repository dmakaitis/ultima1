#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>
#include <vector>
#include <cstdint>

#include <getopt.h>
#include <png.h>

typedef std::vector<uint8_t> ByteArray;
typedef std::vector<uint32_t> DWordArray;

void printAsBinary(uint8_t c) {
    int mask = 0x80;
    while(mask) {
        std::cout << (c & mask ? "*" : ".");
        mask = mask >> 1;
    }
}

void printBitmap(ByteArray& bitmap, int width, int height) {
    auto ptr = bitmap.begin();

    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x += 8) {
            printAsBinary(*ptr++);
        }
        std::cout << std::endl;
    }
}

ByteArray convertToBitmap(png_structp png_ptr, png_infop info_ptr) {
    ByteArray bitmap;

    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);
    png_bytepp row_pointers = png_get_rows(png_ptr, info_ptr);

    for(int y = 0; y < height; y++) {
        png_bytep ptr = row_pointers[y];
        for(int x = 0; x < width; x += 8) {
            bitmap.push_back(*ptr++);
        }
    }

    return bitmap;
}

ByteArray convertToBlockFormat(ByteArray bitmap, int width, int height) {
    ByteArray buffer;

    if(height % 8 != 0) {
        std::cerr << "Image height must be a multiple of 8 to save in block format" << std::endl;
        exit(1);
    }

    int bytesPerRow = width / 8;

    for(int y = 0; y < height; y += 8) {
        int x, xptr;
        for(x = 0, xptr = 0; x < width; x += 8, xptr++) {
            for(int yy = 0; yy < 8; yy++) {
                buffer.push_back(bitmap[(y + yy) * bytesPerRow + xptr]);
            }
        }
    }

    return buffer;
}

int readExtraData(png_structp png_ptr, png_unknown_chunkp chunk) {
    if(strcmp((const char*)chunk->name, "daTa") == 0) {
        std::vector<char>* extra = (std::vector<char>*) png_get_user_chunk_ptr(png_ptr);

        char* data = (char*) chunk->data;
        for(int i = 0; i < chunk->size; i++) {
            extra->push_back(*data++);
        }

        return 1;
    } else {
        return 0;
    }
}

void saveFile(const char* filename, ByteArray& buffer, bool compressed) {
    std::ofstream output(filename, std::ios::binary);

    if(compressed) {
        for(auto b = buffer.begin(); b != buffer.end(); b++) {
            uint8_t value = *b;

            output.put(value);

            switch(value) {
                case 0x00:
                case 0x10:
                case 0xff:
                case 0xe6:
                case 0x16:
                case 0x50:
                    int repeats = 0;
                    while(*b == value && b != buffer.end() && repeats < 256) {
                        repeats++;
                        b++;
                    }
                    b--;
                    if(repeats == 256) {
                        repeats = 0;
                    }
                    output.put((uint8_t) repeats);
            }
        }
        // Write end of compressed image marker:
        output.put(0xda);
    } else {
        output.write((const char*) &buffer[0], buffer.size());
    }
}

ByteArray loadPng(const char* filename, int &width, int &height, DWordArray& palette, ByteArray& extraData) {
        
    // Step 3.1 - Setup

    FILE* fp = fopen(filename, "rb");
    if(!fp) {
        std::cerr << "Failed to open input file: " << filename << std::endl;
        exit(1);
    }

    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if(!png_ptr) {
        std::cerr << "Failed to create read PNG struct" << std::endl;
        exit(1);
    }

    png_infop info_ptr = png_create_info_struct(png_ptr);
    if(!info_ptr) {
        std::cerr << "Failed to create PNG info struct" << std::endl;
        exit(1);
    }

    png_set_read_user_chunk_fn(png_ptr, &extraData, readExtraData);

    png_init_io(png_ptr, fp);
    png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    width = png_get_image_width(png_ptr, info_ptr);
    height = png_get_image_height(png_ptr, info_ptr);

    png_colorp paletteData;
    int paletteSize;
    png_get_PLTE(png_ptr, info_ptr, &paletteData, &paletteSize);
    for(int i = 0; i < paletteSize; i++) {
        uint32_t color = paletteData[i].red << 16;
        color |= paletteData[i].green << 8;
        color |= paletteData[i].blue;
        palette.push_back(color);
    }

    std::cout << "Image size: " << width << " x " << height << std::endl;
    std::cout << "Palette size: " << palette.size() << " colors" << std::endl;
    std::cout << "Extra data: " << extraData.size() << " bytes" << std::endl;

    return convertToBitmap(png_ptr, info_ptr);
}

/*
 * Parses arguments, then passes control to displayBitmap
 */
int main(int argc, char** argv) {
    // int width = -1;
    char* filename = NULL;
    char* outFilename = NULL;
    bool help = false;
    bool block = false;
    bool compressed = false;
    bool quiet = false;

    static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "block",      no_argument,        0,  'b' },
        { "compressed", no_argument,        0,  'c' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
        { "quiet",      no_argument,        0,  'q' }
    };

    int option_index = 0;

    int c;
    while((c = getopt_long(argc, argv, "bci:o:w:s:n:q", options, &option_index)) != -1) {
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
            case 'q':
                quiet = true;
                break;
            case '?':
                help = true;
                break;
        }
    }

    if(help || !filename) {
        std::cout << "Usage: " << argv[0] << " [OPTIONS]" << std::endl;
        std::cout << std::endl;
        std::cout << "Options:" <<std::endl;
        std::cout << "  -b, --block         The image is stored as 8x8 blocks of pixels" << std::endl;
        std::cout << "  -c, --compressed    The image is compressed using RLE" << std::endl;
        std::cout << "  -i, --input         Set the input filename (required)" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in PNG format" << std::endl;
        std::cout << "  -q, --quiet         Do not print a copy of the bitmap to console" << std::endl;
        exit(1);
    }

    // Read the PNG image:
        
    int width, height;
    ByteArray extraData;
    DWordArray palette;
    ByteArray bitmap = loadPng(filename, width, height, palette, extraData);

    if(!quiet) {
        printBitmap(bitmap, width, height);
    }

    if(outFilename) {
        ByteArray buffer = block ? convertToBlockFormat(bitmap, width, height) : bitmap;

        // Append any extra data...
        buffer.insert(buffer.end(), extraData.begin(), extraData.end());

        saveFile(outFilename, buffer, compressed);
    }

    return 0;
}