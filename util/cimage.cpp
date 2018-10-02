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

const uint32_t C64_PALETTE[] = {
    0x00000000,     // black
    0x00ffffff,     // white
    0x0068372b,     // red
    0x0070a4b2,     // cyan
    0x006f3d86,     // purple
    0x00588d43,     // green
    0x00352879,     // blue
    0x00b8c76f,     // yellow
    0x006f4f25,     // orange
    0x00433900,     // brown
    0x009a6759,     // light red
    0x00444444,     // dark grey
    0x006c6c6c,     // grey
    0x009ad284,     // light green
    0x006c5eb5,     // light blue
    0x00959595      // light grey
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
 * Prints the bitmap as a series of binary outputs to the console.
 *
 * c    the byte to print.
 * on   the character to print for on bits.
 * off  the character to print for off bits.
 */
void printBitmap(ByteArray& bitmap, int width, int height, char on = '*', char off = '.') {
    auto ptr = bitmap.begin();

    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x += 8) {
            printAsBinary(*ptr++, on, off);
        }
        std::cout << std::endl;
    }
}

/*
 * Constructs a palette for a greyscale image. The palette will contain
 * the appropriate number of entries for the given bit depth with
 * luminosity progressing linearly from 0.0 to 1.0 from the first to
 * last entries of the palette.
 *
 * bitDepth     the bit depth of the image.
 */
DWordArray buildGreyscalePalette(int bitDepth) {
    DWordArray palette;

    int numColors;
    unsigned int step;

    // Possible bit depths: 1, 2, 4, 8, 16
    switch(bitDepth) {
        case 1:
            numColors = 2;
            step = 0x100;
            break;
        case 2:
            numColors = 4;
            step = 0x40;
            break;
        case 4:
            numColors = 16;
            step = 0x10;
            break;
        case 8:
            numColors = 256;
            step = 0x01;
            break;
        case 16:
            // TODO: Support 16 bit greyscale...
        default:
            std::cerr << "ERROR: Unsupported bit depth for greyscale image: " << bitDepth << std::endl;
            exit(1);        
    }

    uint32_t luminosity = 0x00;
    for(int i = 0; i < numColors; i++) {
        uint32_t color = (luminosity << 16) | (luminosity << 8) | luminosity;
        palette.push_back(color);
        luminosity += step;
        if(luminosity >= 256) {
            luminosity = 0xff;
        }
    }

    return palette;
}

/*
 * Reads a color palette from the PNG image.
 *
 * png_ptr      the pointer to the PNG struct.
 * info_ptr     the pointer to the PNG image info header.
 */
DWordArray readColorPalette(png_structp png_ptr, png_infop info_ptr) {
    DWordArray palette;

    png_colorp paletteData;
    int paletteSize;

    png_get_PLTE(png_ptr, info_ptr, &paletteData, &paletteSize);
    for(int i = 0; i < paletteSize; i++) {
        uint32_t color = paletteData[i].red << 16;
        color |= paletteData[i].green << 8;
        color |= paletteData[i].blue;
        palette.push_back(color);
    }

    return palette;
}

/*
 * Gets a palette that can be used to translate bitmap values in a
 * PNG image to their actual colors.
 *
 * png_ptr      the pointer to the PNG struct.
 * info_ptr     the pointer to the PNG image info header.
 */
DWordArray getPalette(png_structp png_ptr, png_infop info_ptr) {
    DWordArray palette;

    png_byte color_type = png_get_color_type(png_ptr, info_ptr);

    switch(color_type) {
        case 0:
            // greyscale
            palette = buildGreyscalePalette(png_get_bit_depth(png_ptr, info_ptr));
            break;
        case 3:
            // Palette based
            palette = readColorPalette(png_ptr, info_ptr);
            break;
        case 2:
            // TODO: support RBG images
            // RGB - possible bit depths: 8, 16
        case 4:
            // TODO: support LA images
            // Greyscale + alpha - possible bit depths: 8, 16
        case 6:
            // TODO: support RBGA images
            // RGBA - possible bit depths: 8, 16
        default:
            std::cerr << "ERROR: Unsupported color type: " << (int) color_type << std::endl;
            exit(1);
    }

    return palette;
}

/*
 * Unpacks the pixels from a row of bytes in a PNG image. The resulting
 * vector will contain exactly one pixel per entry.
 *
 * rowBytes     the number of bytes per row of the image.
 * width        the width of the image.
 * bitDepth     the bit depth of the image.
 */
DWordArray unpackPixels(png_bytep rowBytes, int width, int bitDepth) {
    DWordArray pixels;

    png_byte mask;
    int rot;
    int x;
    uint32_t index;

    int pixelsPerByte;
    png_byte initialMask;

    // Possible bit depths: 1, 2, 4, 8, 16
    switch(bitDepth) {
        case 1:
            pixelsPerByte = 8;
            break;
        case 2:
            pixelsPerByte = 4;
            break;
        case 4:
            pixelsPerByte = 2;
            break;
        case 8:
            pixelsPerByte = 1;
            break;
        case 16:
            // TODO: Support 16 bpp images...
        default:
            std::cerr << "ERROR: Unsupported bit depth: " << bitDepth << std::endl;
            exit(1);        
    }

    for(x = 0; x < width; x += pixelsPerByte, rowBytes++) {
        rot = 8 - bitDepth;
        mask = (0xff << rot) & 0xff;
        while(mask) {
            index = (*rowBytes & mask) >> rot;
            pixels.push_back(index);
            mask >>= bitDepth;
            rot -= bitDepth;
        }
    }

    return pixels;
}

/*
 * Converts a PNG image to true color. The resulting vector will contain
 * exactly one entry per pixel, where each entry will be an RGBA value,
 * with the alpha being in the most significant byte, then red, green, and
 * finally blue in the least significant byte.
 *
 * png_ptr      the pointer to the PNG struct.
 * info_ptr     the pointer to the PNG image info header.
 */
DWordArray convertToTrueColor(png_structp png_ptr, png_infop info_ptr) {
    DWordArray image;

    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);
    png_bytepp row_pointers = png_get_rows(png_ptr, info_ptr);
    int bit_depth = png_get_bit_depth(png_ptr, info_ptr);
    png_byte color_type = png_get_color_type(png_ptr, info_ptr);

    DWordArray palette;
    DWordArray rowPixels;

    switch(color_type) {
        case 0:
        case 3:
            palette = getPalette(png_ptr, info_ptr);
            for(int y = 0; y < height; y++) {
                rowPixels = unpackPixels(row_pointers[y], width, bit_depth);
                for(DWordArray::const_iterator x = rowPixels.begin(); x != rowPixels.end(); x++) {
                    image.push_back(palette[*x]);
                }
            }
            break;
        default:
            std::cerr << "ERROR: Unsupported color type: " << (int) color_type << std::endl;
    }

    return image;
}

/*
 * Calculates the difference between to colors and returns it as
 * a double value. There are no particular units of measurement, but
 * differences between colors can be compared to find which combination
 * of colors are more similar. Differences are calculated in RGB space.
 *
 * colorA   the first color to compare.
 * colorB   the second color to compare.
 */
double calculateColorDifference(uint32_t colorA, uint32_t colorB) {
    uint32_t mask = 0x00ff0000;
    int rotate = 16;

    double diff = 0.0;

    while(mask) {
        double valueA = (double)((colorA & mask) >> rotate) / 255.0;
        double valueB = (double)((colorB & mask) >> rotate) / 255.0;

        double d = valueB - valueA;

        diff += d * d;

        mask >>= 8;
        rotate -= 8;
    }

    return diff;
}

/*
 * Converts a PNG image into a bitmap that can be displayed on the C64.
 * If available, additional data containing the color memory of the C64
 * can be passed in to assist in converting the image in such a way as 
 * the bitmap will most resemble the original PNG image. Otherwise, the
 * method will assume that on pixels will be displayed as white, and off
 * pixels as black, and convert the image accordingly.
 *
 * png_ptr              the pointer to the PNG struct.
 * info_ptr             the pointer to the PNG image info header.
 * extra                any extra data that might contain color memory values.
 * colorMemoryOffset    the offset into extra where color memory values can be found,
 *                      or -1 to indicate that no color memory values are present.
 * quiet                if console output should be suppressed.
 *
 * TODO: If no color memory data is present, enable this method to calculate
 *       optimal color memory values to display the input image.
 */
ByteArray convertToBitmap(png_structp png_ptr, png_infop info_ptr, ByteArray& extra, int colorMemoryOffset, bool quiet) {
    ByteArray bitmap;

    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);

    DWordArray image = convertToTrueColor(png_ptr, info_ptr);

    int ptr = 0;

    for(int y = 0; y < height; y++) {
        int colorMemPtr = colorMemoryOffset + 40 * (y / 8);

        for(int x = 0; x < width; x += 8) {
            uint8_t colorMemValue = colorMemoryOffset >= 0 && colorMemPtr < extra.size() ? extra[colorMemPtr++] : 0x10;

            uint32_t offColor = C64_PALETTE[colorMemValue & 0x0f];
            uint32_t onColor = C64_PALETTE[(colorMemValue & 0xf0) >> 4];

            uint8_t mask = 0x80;
            uint8_t byte = 0x00;

            while(mask) {
                uint32_t color = image[ptr++];

                double diffOn = calculateColorDifference(color, onColor);
                double diffOff = calculateColorDifference(color, offColor);

                if(diffOff > diffOn) {
                    byte |= mask;
                }

                mask >>= 1;
            }

            bitmap.push_back(byte);
        }
    }

    if(!quiet) {
        std::cout << "Bitmap size: " << bitmap.size() << " bytes" << std::endl;
    }

    return bitmap;
}

/*
 * Converts a row-sequential bitmap into C64 block format so that the image is
 * stored as a sequence of 8x8 bitmaps.
 *
 * bitmap   the row-sequential bitmap to convert.
 * width    the bitmap width.
 * height   the bitmap height.
 */
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

/*
 * Converts a row-sequential bitmap into C64 big-block format so that the image is
 * stored as a sequence of 16x16 bitmaps.
 *
 * bitmap   the row-sequential bitmap to convert.
 * width    the bitmap width.
 * height   the bitmap height.
 */
ByteArray convertToBigBlockFormat(ByteArray bitmap, int width, int height) {
    ByteArray buffer;

    if(width % 16 != 0) {
        std::cerr << "Image width must be a multiple of 16 to save in big-block format" << std::endl;
        exit(1);
    }
    if(height % 16 != 0) {
        std::cerr << "Image height must be a multiple of 16 to save in big-block format" << std::endl;
        exit(1);
    }

    int bytesPerRow = width / 8;

    for(int y = 0; y < height; y += 16) {
        for(int x = 0; x < (width / 8); x += 2) {
            for(int yy = 0; yy < 16; yy += 8) {
                for(int xx = 0; xx < 2; xx++) {
                    for(int yyy = 0; yyy < 8; yyy++) {
                        buffer.push_back(bitmap[(y + yy + yyy) * bytesPerRow + (x + xx)]);
                    }
                }
            }
        }
    }

    return buffer;
}

/*
 * Reads any extra data that might be stored in the PNG image.
 * The method will look for extra data in a 'daTa' chunk in the
 * PNG image.
 *
 * png_ptr  the PNG structure.
 * chunk    the unknown chunk that might contain extra data.
 */
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

/*
 * Saves the buffer to a file.
 *
 * filename     the output filename.
 * buffer       the sequence of bytes to save.
 * compressed   if the data should be compressed using RLE compression.
 */
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

/*
 * Loads a PNG file and returns it as a bitmap.
 *
 * filename             the PNG image filename.
 * width                the width of the image will be output to this variable.
 * height               the height of the image will be output to this variable.
 * extraData            any extra data in the PNG file will be stored in this vector.
 * colorMemoryOffset    offset into 'extraData' where suggested color memory values can be
 *                      found once loaded from the PNG image, or -1 to indicate that no
 *                      color memory values are expected to be found in the image.
 * quiet                if console output should be suppressed.
 */ 
ByteArray loadPng(const char* filename, int &width, int &height, ByteArray& extraData, int colorMemoryOffset, bool quiet) {
        
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

    DWordArray palette = getPalette(png_ptr, info_ptr);

    if(!quiet) {
        std::cout << "Image size: " << width << " x " << height << std::endl;
        std::cout << "Palette size: " << palette.size() << " colors" << std::endl;
        std::cout << "Extra data: " << extraData.size() << " bytes" << std::endl;
    }

    return convertToBitmap(png_ptr, info_ptr, extraData, colorMemoryOffset, quiet);
}

/*
 * Parses arguments, then converts the image.
 */
int main(int argc, char** argv) {
    // int width = -1;
    char* filename = NULL;
    char* outFilename = NULL;
    bool help = false;
    bool block = false;
    bool bigBlock = false;
    bool compressed = false;
    bool quiet = false;
    int colorMemoryOffset = -1;

    static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "block",      no_argument,        0,  'b' },
        { "big-block",  no_argument,        0,  'B' },
        { "compressed", no_argument,        0,  'c' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
        { "quiet",      no_argument,        0,  'q' },
        { "color",      required_argument,  0,  'C' }
    };

    int option_index = 0;

    int c;
    while((c = getopt_long(argc, argv, "bBci:o:w:s:n:qC:", options, &option_index)) != -1) {
        switch(c) {
            case 'b':
                block = true;
                break;
            case 'B':
                block = true;
                bigBlock = true;
                break;
            case 'c':
                compressed = true;
                break;
            case 'C':
                colorMemoryOffset = atoi(optarg);
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
        std::cout << "  -B, --big-block     The image is stored as 16x16 blocks of pixels (implies -b)" << std::endl;
        std::cout << "  -c, --compressed    The image is compressed using RLE" << std::endl;
        std::cout << "  -C, --color         Offset into extra data where expected color memory is located" << std::endl;
        std::cout << "  -i, --input         Set the input filename (required)" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in PNG format" << std::endl;
        std::cout << "  -q, --quiet         Do not print a copy of the bitmap to console" << std::endl;
        exit(1);
    }

    // Read the PNG image:
        
    int width, height;
    ByteArray extraData;
    ByteArray bitmap = loadPng(filename, width, height, extraData, colorMemoryOffset, quiet);

    if(!quiet) {
        printBitmap(bitmap, width, height);
    }

    if(outFilename) {
        ByteArray buffer = bigBlock ? convertToBigBlockFormat(bitmap, width, height) : 
                                (block ? convertToBlockFormat(bitmap, width, height) : bitmap);

        // Append any extra data...
        buffer.insert(buffer.end(), extraData.begin(), extraData.end());

        saveFile(outFilename, buffer, compressed);
    }

    return 0;
}