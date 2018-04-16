#include <fstream>
#include <iterator>
#include <algorithm>
#include <iostream>
#include <vector>

#include <string.h>
#include <getopt.h>
#include <png.h>

const png_color C64_PALETTE[] = {
    0x00, 0x00, 0x00,   // black
    0xff, 0xff, 0xff,   // white
    0x68, 0x37, 0x2b,   // red
    0x70, 0xa4, 0xb2,   // cyan
    0x6f, 0x3d, 0x86,   // purple
    0x58, 0x8d, 0x43,   // green
    0x35, 0x28, 0x79,   // blue
    0xb8, 0xc7, 0x6f,   // yellow
    0x6f, 0x4f, 0x25,   // orange
    0x43, 0x39, 0x00,   // brown
    0x9a, 0x67, 0x59,   // light red
    0x44, 0x44, 0x44,   // dark grey
    0x6c, 0x6c, 0x6c,   // grey
    0x9a, 0xd2, 0x84,   // light green
    0x6c, 0x5e, 0xb5,   // light blue
    0x95, 0x95, 0x95    // light grey
};

/*
 * Prints a byte of data in binary format to the console.
 *
 * c    the byte to print.
 * on   the character to print for on bits.
 * off  the character to print for off bits.
 */
void printAsBinary(uint8_t c, char on = '*', char off = '.') {
    int mask = 0x80;
    while(mask) {
        std::cout << (c & mask ? on : off);
        mask = mask >> 1;
    }
}

/*
 * Filters an input stream, optionally reading it as a RLE compressed
 * stream. The RLE works by reading the stream normally, but the
 * following byte values are run-length encoded, with the following
 * byte being the number of repeats (with '0x00' being read as 256):
 *
 *      0x00, 0x10, 0x16, 0x50, 0xe6, 0xff
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

    int size;
    int count;

public:
    StreamFilter(char *filename, bool compressed, int skip, int size) : 
        input(filename, std::ios::binary), 
        compressed(compressed),
        repeats(0),
        endOfCompressed(false),
        size(size),
        count(0)
    {
        input.ignore(skip);
    }

    int get() {
        while(repeats == 0) {
            byte = input.get();
            ++count;

            if(compressed) {
                switch(byte) {
                    case 0xda:
                        endOfCompressed = true;
                        repeats = 1;
                        break;
                    case 0x00:
                    case 0x10:
                    case 0xff:
                    case 0xe6:
                    case 0x16:
                    case 0x50:
                        repeats = input.get();
                        ++count;

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
        bool maxBytesRead = size >= 0 ? count > size : false;
        return endOfCompressed || maxBytesRead || input.eof();
    }

};

/*
 * Loads data from a file. The data may be optionally compressed, and may be located
 * at an offset from the beginning of the file.
 *
 * If the data is compressed, then and byte with one of the following values will be
 * followed with a byte containing the number of times that value should be repeated
 * in the output (with a repeat value of 0x00 being interpreted as 256 repetitions):
 * 0x00, 0x10, 0x16, 0x50, 0xe6, 0xff. In addition, a value of 0xda will be interpreted
 * as the end of the data stream, even if 'size' bytes have not yet been read.
 *
 * filename         the name of the file containing the data.
 * compressed       true if the data is compressed; false otherwise.
 * skip             the number of bytes from the beginning of the file where the data
 *                  to be read is located.
 * size             the number of bytes to read, or -1 to read until the end of the
 *                  input stream. This number of bytes may not be read if the input
 *                  stream ends before this number of bytes has been reached. In the
 *                  case of compressed data, this is the number of compressed byte
 *                  (the resulting data may be larger).
 */
std::vector<char> readData(char *filename, bool compressed, int skip, int size) {
    std::vector<char> data;

    StreamFilter input(filename, compressed, skip, size);

    int byte = input.get();
    while(!input.eof()) {
        data.push_back(byte);
        byte = input.get();
    }

    return data;
}

/*
 * Displays a bitmap image as text on the screen. The bitmap may be read in either
 * row sequential format, or in 8x8 block format (like a C64 bitmap). In either
 * case, the image width must be given and must be a multiple of 8.
 *
 *  data            the image data.
 *  imageWidth      the width of the bitmap in pixels.
 *  imageHeight     the height of the bitmap in pixels.
 *  blockFormat     true if the image is stored as 8x8 blocks; false if the image is row sequential.
 */
std::vector<char> getBitmap(const std::vector<char>& data, int imageWidth, int imageHeight, bool blockFormat) {
    std::vector<char> bitmap;

    if(imageWidth % 8 != 0) {
        std::cerr << "ERROR: Image width must be a multiple of 8" << std::endl;
        return bitmap;
    }

    auto dataIterator = data.begin();
    int rowsRead = 0;

    if(blockFormat) {
        if(imageHeight % 8 != 0) {
            std::cerr << "ERROR: Image height must be a multiple of 8 when reading in block mode" << std::endl;
            return bitmap;
        }

        // Set up a buffer where we can rearrange the bytes back into row sequential order

        std::unique_ptr<char[]> buffer(new char[imageWidth]);

        int bytesPerRow = imageWidth / 8;

        int count = 0;
        int colPtr = 0;
        int ptr = 0;

        while(dataIterator != data.end() && rowsRead < imageHeight) {
            buffer[ptr] = *dataIterator++;

            count++;
            if(count % imageWidth == 0) {
                // Add buffer to the bitmap
                for(int i = 0; i < imageWidth; i++) {
                    bitmap.push_back(buffer[i]);
                }
                
                count = 0;
                colPtr = 0;
                ptr = colPtr;
                rowsRead += 8;
            } else if(count % 8 == 0) {
                colPtr++;
                ptr = colPtr;
            } else {
                ptr += bytesPerRow;
            }
        }
    } else {
        int columnsRead = 0;

        while(dataIterator != data.end() && rowsRead < imageHeight) {
            bitmap.push_back(*dataIterator++);
            columnsRead += 8;
            if(columnsRead >= imageWidth) {
                columnsRead = 0;
                ++rowsRead;
            }
        }
    }

    return bitmap;
}

/*
 * Prints a bitmap to the console output.
 *
 * bitmap           the bitmap data.
 * bytesPerRow      the number of byte in each row of the bitmap.
 */
void printBitmap(const std::vector<char>& bitmap, int bytesPerRow) {
    int count = 0;
    for(auto ptr = bitmap.begin(); ptr != bitmap.end(); ptr++) {
        printAsBinary(*ptr);
        count++;
        if(count >= bytesPerRow) {
            count = 0;
            std::cout << std::endl;
        }
    }

    std::cout << std::endl;
}

/*
 * Converts a 1bpp bitmap to a 4bpp image using an image of C64
 * color memory to determine the color of each pixel in the bitmap.
 *
 * bitmap           the bitmap data.
 * colorMem         image of color memory.
 * width            image width in pixels.
 * height           image height in pixels.
 * colorOffset      the offset where color data actually starts in color memory.
 */
std::vector<char> convertTo4bpp(const std::vector<char>& bitmap, const std::vector<char>& colorMem, int width, int height, int colorOffset) {
    std::vector<char> output;

    int bytesPerRow = width / 8;

    int bitmapPtr = 0;

    for(int y = 0; y < height; y++) {
        int colorPtr = colorOffset + bytesPerRow * (y / 8);

        for(int x = 0; x < bytesPerRow; x++) {
            unsigned char bitmapByte = (unsigned char)bitmap[bitmapPtr++];
            unsigned char colorByte = (unsigned char)colorMem[colorPtr++];

            unsigned char offColor = colorByte & 0x0f;
            unsigned char onColor = (colorByte >> 4) & 0x0f;

            unsigned char mask = 0x80;

            for(int i = 0; i < 4; i++) {
                unsigned char out = bitmapByte & mask ? onColor : offColor;
                out <<= 4;
                mask >>= 1;
                out |= bitmapByte & mask ? onColor : offColor;
                mask >>= 1;

                output.push_back((char) out);
            }
        }
    }

    return output;
}

/*
 * Saves a bitmap as a PNG file.
 *
 * filename         the output filename.
 * bitmap           the bitmap data.
 * width            the width of the bitmap in pixels.
 * height           the height of the bitmap in pixels.
 * extra            any extra data that should be included that isn't part of the bitmap.
 * color            true if the image should be saved as a 4bpp color image; false for a 1bpp black and white image.
 * colorOffset      the offset into 'extra' data where the C64 color map is located.
 */
void saveAsPng(const char* filename, const std::vector<char>& bitmap, int width, int height, const std::vector<char>& extra, bool color, int colorOffset) {
    int bytesPerRow = width / 8;

    if(color && extra.size() < (width / 8) * (height / 8)) {
        std::cout << "WARNING: Not enough color data to convert to color bitmap - falling back to 1bpp" << std::endl;
        std::cout << "(need " << ((width / 8) * (height / 8)) << "bytes; read " << extra.size() << " bytes)" << std::endl;
        color = false;
    }

    // Step 4.1 - Setup

    FILE* fp = fopen(filename, "wb");
    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info_ptr = png_create_info_struct(png_ptr);
    // setup error callbacks
    png_init_io(png_ptr, fp);

    // Step 4.2 - Write callbacks

    // Step 4.3 - Info contents

    int bit_depth = color ? 4 : 1;
    int color_type = color ? PNG_COLOR_TYPE_PALETTE : PNG_COLOR_TYPE_GRAY;

    png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, 
        PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

    if(color) {
        png_set_PLTE(png_ptr, info_ptr, C64_PALETTE, 16);
    }

    if(extra.size() > 0) {
        png_unknown_chunk unknownChunk;

        strcpy((char *)unknownChunk.name, "daTa");
        unknownChunk.data = (unsigned char *)&extra[0];
        unknownChunk.size = extra.size();
        unknownChunk.location = PNG_AFTER_IDAT;

        png_set_unknown_chunks(png_ptr, info_ptr, &unknownChunk, 1);
    }

    // Step 4.5 - Write file

    std::vector<char> data = color ? convertTo4bpp(bitmap, extra, width, height, colorOffset) : bitmap;
    bytesPerRow *= color ? 4 : 1;

    std::vector<png_bytep> row_pointers;
    png_bytep bitmapPtr = (png_bytep)(&(*(data.begin())));
    for(int i = 0; i < height; i++) {
        row_pointers.push_back(bitmapPtr);
        bitmapPtr += bytesPerRow;
    }
    png_set_rows(png_ptr, info_ptr, &(*(row_pointers.begin())));

    png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);
    

    fclose(fp);
}

/*
 * Parses arguments, then passes control to displayBitmap
 */
int main(int argc, char** argv) {
    int width = -1;
    int height = -1;
    char* filename = NULL;
    char* outFilename = NULL;
    bool help = false;
    bool block = false;
    bool compressed = false;
    int skip = 0;
    int numbytes = -1;
    bool quiet = false;
    bool color = false;
    int colorOffset = 0;

    static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "block",      no_argument,        0,  'b' },
        { "compressed", no_argument,        0,  'c' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
        { "width",      required_argument,  0,  'w' },
        { "skip",       required_argument,  0,  's' },
        { "numbytes",   required_argument,  0,  'n' },
        { "quiet",      no_argument,        0,  'q' },
        { "height",     required_argument,  0,  'h' },
        { "color",      required_argument,  0,  'C' }
    };

    int option_index = 0;

    int c;
    while((c = getopt_long(argc, argv, "bci:o:w:s:n:qh:C:", options, &option_index)) != -1) {
        switch(c) {
            case 'b':
                block = true;
                break;
            case 'c':
                compressed = true;
                break;
            case 'C':
                color = true;
                colorOffset = atoi(optarg);
                break;
            case 'h':
                height = atoi(optarg);
                break;
            case 'i':
                filename = optarg;
                break;
            case 'n':
                numbytes = atoi(optarg);
                break;
            case 'o':
                outFilename = optarg;
                break;
            case 'q':
                quiet = true;
                break;
            case 's':
                skip = atoi(optarg);
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
        std::cout << "  -b, --block         The image is stored as 8x8 blocks of pixels" << std::endl;
        std::cout << "  -c, --compressed    The image is compressed using RLE" << std::endl;
        std::cout << "  -C, --color         The image is in color (color memory should immediately follow bitmap memory in the data)" << std::endl;
        std::cout << "  -h, --height        The image height" << std::endl;
        std::cout << "  -i, --input         Set the input filename (required)" << std::endl;
        std::cout << "  -n, --numbytes      How many bytes of data to read for the image" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in PNG format" << std::endl;
        std::cout << "  -s, --skip          How many bytes to skip in the input file before reading the image" << std::endl;
        std::cout << "  -w, --width         Set the image width in pixels (required)" << std::endl;
        exit(1);
    }

    // Read the data from the input file:

    std::vector<char> data = readData(filename, compressed, skip, numbytes);

    if(!quiet) {
        std::cout << "Bytes read: " << data.size() << std::endl;
    }

    int bytesPerRow = width / 8;
    if(height < 0) {
        height = data.size() / bytesPerRow;
    }
    if(!quiet) {
        std::cout << "Image size: " << width << " x " << height << std::endl;
    }

    // Get the actual bitmap image from the data:

    std::vector<char> bitmap = getBitmap(data, width, height, block);
    std::vector<char> extra(data.begin() + bitmap.size(), data.end());

    if(!quiet) {
        std::cout << extra.size() << " extra bytes in input data" << std::endl;
    }
    
    // Print the bitmap if we're not running in quiet mode:

    if(!quiet) {
        printBitmap(bitmap, bytesPerRow);
    }

    // Save it as a PNG:

    if(outFilename) {
        saveAsPng(outFilename, bitmap, width, height, extra, color, colorOffset);
    }

    return 0;
}