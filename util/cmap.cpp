#include <fstream>
#include <iostream>

#include <getopt.h>

int flush(int tile, int tileCount, std::ofstream &output) {
	int count = 0;

	while(tileCount > 0) {
		int tiles = tileCount > 31 ? 31 : tileCount;
		int out = (tiles << 3) | (tile & 0x07);

		output.put(out);
		++count;

		tileCount -= tiles;
	}

	return count;
}

int main(int argc, char** argv) {
	char *filename = NULL;
	char *outFilename = NULL;
	bool help = false;

	static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
    };

    int option_index = 0;

	int c;
    while((c = getopt_long(argc, argv, "i:o:", options, &option_index)) != -1) {
        switch(c) {
            case 'i':
                filename = optarg;
                break;
            case 'o':
                outFilename = optarg;
                break;
            case '?':
                help = true;
                break;
        }
    }

    if(help || !filename || !outFilename) {
        std::cout << "Usage: " << argv[0] << " [OPTIONS]" << std::endl;
        std::cout << std::endl;
        std::cout << "Options:" <<std::endl;
        std::cout << "  -i, --input         Set the input filename (required)" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in TXT format (required)" << std::endl;
        exit(1);
    }

    std::ifstream input(filename);
    std::ofstream output(outFilename, std::ios::binary);

    int tile = -1;
    int tileCount = 0;
    int nextTile = 0;
    int inCount = 0;
    int outCount = 0;

    while(!input.eof()) {
    	int in = input.get();
    	switch(in) {
    		case '~':
    			nextTile = 0;
    			break;
    		case '.':
    			nextTile = 1;
    			break;
    		case '*':
    			nextTile = 2;
    			break;
    		case '^':
    			nextTile = 3;
    			break;
    		case 'H':
    			nextTile = 4;
    			break;
    		case 't':
    			nextTile = 5;
    			break;
    		case '=':
    			nextTile = 6;
    			break;
    		case 'X':
    			nextTile = 7;
    			break;
    		default:
    			nextTile = -1;
    	}

   		if(nextTile >= 0) {
   			if(tile == nextTile) {
   				++tileCount;
   			} else {
   				outCount += flush(tile, tileCount, output);
   				tile = nextTile;
   				tileCount = 1;
   			}

   			++inCount;
   		}
    }

    outCount += flush(tile, tileCount, output);

    output.put(0);
    ++outCount;

    std::cout << inCount << " bytes read." << std::endl;
    std::cout << outCount << " bytes written." << std::endl;

	return 0;
}
