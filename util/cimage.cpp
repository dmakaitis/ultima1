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
    // int skip = 0;
    // int numbytes = -1;
    bool quiet = false;

    static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "block",      no_argument,        0,  'b' },
        { "compressed", no_argument,        0,  'c' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
        // { "width",      required_argument,  0,  'w' },
        // { "skip",       required_argument,  0,  's' },
        // { "numbytes",   required_argument,  0,  'n' },
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
            // case 'n':
            //     numbytes = atoi(optarg);
            //     break;
            case 'o':
                outFilename = optarg;
                break;
            case 'q':
                quiet = true;
                break;
            // case 's':
            //     skip = atoi(optarg);
            //     break;
            // case 'w':
            //     width = atoi(optarg);
            //     break;
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
        // std::cout << "  -n, --numbytes      How many bytes to read for the image" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in PNG format" << std::endl;
        // std::cout << "  -s, --skip          How many bytes to skip in the input file before reading the image" << std::endl;
        // std::cout << "  -w, --width         Set the image width in pixels (required)" << std::endl;
        exit(1);
    }

    // std::vector<char> bitmap = loadBitmap(filename, width, block, compressed, skip, numbytes);

    // int bytesPerRow = width / 8;

    // // Now, print the bitmap...
    // if(!quiet) {
    //     int count = 0;
    //     for(std::vector<char>::const_iterator ptr = bitmap.begin(); ptr != bitmap.end(); ptr++) {
    //         printAsBinary(*ptr);
    //         count++;
    //         if(count >= bytesPerRow) {
    //             count = 0;
    //             std::cout << std::endl;
    //         }
    //     }

    //     std::cout << std::endl;
    // }

    // int height = bitmap.size() / bytesPerRow;
    // int bit_depth = 1;

    // std::cout << "Image size: " << width << " x " << bitmap.size() / bytesPerRow << std::endl;

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

    png_infop end_info = png_create_info_struct(png_ptr);
    if(!end_info) {
        std::cerr << "Failed to create PNG end info struct" << std::endl;
        exit(1);
    }

    png_init_io(png_ptr, fp);

    png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);

    std::unique_ptr<png_bytep[]> row_pointers(new png_bytep[height]);

    png_read_image(png_ptr, row_pointers);

    //     png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    //     png_infop info_ptr = png_create_info_struct(png_ptr);
    //     // setup error callbacks
    //     png_init_io(png_ptr, fp);

    //     // Step 4.2 - Write callbacks

    //     // Step 4.3 - Info contents

    //     png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, PNG_COLOR_TYPE_GRAY, 
    //         PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

    //     // Step 4.5 - Write file

    //     std::vector<png_bytep> row_pointers;
    //     png_bytep bitmapPtr = (png_bytep)(&(*(bitmap.begin())));
    //     for(int i = 0; i < height; i++) {
    //         row_pointers.push_back(bitmapPtr);
    //         bitmapPtr += bytesPerRow;
    //     }
    //     png_set_rows(png_ptr, info_ptr, &(*(row_pointers.begin())));

    //     png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    //     fclose(fp);
    // }
    return 0;
}