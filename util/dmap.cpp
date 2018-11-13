#include <fstream>
#include <iostream>

#include <getopt.h>

void writeMap(char *filename, int skip, std::ostream &out) {
	std::ifstream input(filename, std::ios::binary);
	input.ignore(skip);

	const char valueMap[] = { '~', '.', '*', '^', 'H', 't', '=', 'X' };

	int rowCount = 0;
	int data = input.get();
	int sourceCount = 0;
	while(data && !input.eof()) {
		++sourceCount;

		int reps = data >> 3;
		int value = data & 0x07;

		for(int i = 0; i < reps; i++) {
			out << valueMap[value];
			rowCount++;
			if(rowCount >= 64) {
				out << std::endl;
				rowCount = 0;
			}
		}

		data = input.get();
	}

	std::cout << "Read " << sourceCount << " bytes." << std::endl;
}

int main(int argc, char** argv) {
	char *filename = NULL;
	char *outFilename = NULL;
	int skip = 0;
	bool help = false;

	static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "input",      required_argument,  0,  'i' },
        { "output",     required_argument,  0,  'o' },
        { "skip",       required_argument,  0,  's' }
    };

    int option_index = 0;

	int c;
    while((c = getopt_long(argc, argv, "i:o:s:", options, &option_index)) != -1) {
        switch(c) {
            case 'i':
                filename = optarg;
                break;
            case 'o':
                outFilename = optarg;
                break;
            case 's':
                skip = atoi(optarg);
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
        std::cout << "  -i, --input         Set the input filename (required)" << std::endl;
        std::cout << "  -o, --output        Set the output filename to save in TXT format" << std::endl;
        std::cout << "  -s, --skip          How many bytes to skip in the input file before reading the map" << std::endl;
        exit(1);
    }

    if(outFilename) {
    	std::ofstream output(outFilename);
    	writeMap(filename, skip, output);
    } else {
	    writeMap(filename, skip, std::cout);
    }

	return 0;
}
