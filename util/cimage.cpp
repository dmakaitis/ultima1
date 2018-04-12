#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>
#include <vector>

#include <getopt.h>
#include <png.h>

void printAsBinary(char c) {
    int mask = 0x80;
    while(mask) {
        std::cout << (c & mask ? "*" : ".");
        mask = mask >> 1;
    }
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
        exit(1);
    }

    // Read the PNG image:
        
    // Step 3.1 - Setup

    FILE* fp = fopen(filename, "rb");
    if(!fp) {
        std::cerr << "Failed to open input file: " << filename << std::endl;
        exit(1);
    }

    // fread(header, 1, number, fp);
    // is_png = !png_sig_cmp(header, 0, number);
    // if(!is_png) {
    //     std::cerr << "Input file is not a PNG image" << std::endl;
    //     exit(1);
    // }

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

    png_init_io(png_ptr, fp);
    png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);

    std::cout << "Image size: " << width << " x " << height << std::endl;

    png_bytepp row_pointers = png_get_rows(png_ptr, info_ptr);

    if(!quiet) {
        for(int y = 0; y < height; y++) {
            png_bytep ptr = row_pointers[y];
            // std::cout << "Got pointer for row " << y << ": " << (long) ptr << std::endl;
            for(int x = 0; x < width; x += 8) {
                printAsBinary(*ptr++);
            }
            std::cout << std::endl;
        }
    }

    if(outFilename) {

        // Copy data to buffer

        std::vector<char> buffer;
        if(block) {
            if(height % 8 != 0) {
                std::cerr << "Image height must be a multiple of 8 to save in block format" << std::endl;
                exit(1);
            }

            for(int y = 0; y < height; y += 8) {
                int x, xptr;
                for(x = 0, xptr = 0; x < width; x += 8, xptr++) {
                    for(int yy = 0; yy < 8; yy++) {
                        buffer.push_back(row_pointers[y + yy][xptr]);
                    }
                }
            }
        } else {
            for(int y = 0; y < height; y++) {
                png_bytep ptr = row_pointers[y];
                for(int x = 0; x < width; x += 8) {
                    buffer.push_back(*ptr++);
                }
            }
        }

        // Now write the buffer to the file

        std::ofstream output(outFilename, std::ios::binary);

        if(compressed) {
            for(std::vector<char>::const_iterator b = buffer.begin(); b != buffer.end(); b++) {
                char value = *b;

                output.put(value);

                switch((unsigned char) value) {
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
                        output.put((unsigned char) repeats);
                }
            }
            // Write end of compressed image marker:
            output.put(0xda);
        } else {
            output.write(&buffer[0], buffer.size());
        }
    }

    return 0;
}