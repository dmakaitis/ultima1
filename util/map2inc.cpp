#include <fstream>
#include <iostream>
#include <sstream>
#include <map>
#include <vector>

#include <getopt.h>

typedef std::map<std::string, int> SymbolMap;
typedef std::vector<std::string> StringArray;

SymbolMap loadSymbolMap(const char* mapFilename) {
	SymbolMap symbols;
	bool inExportsSection = false;

	std::ifstream mapFile(mapFilename);
	if(mapFile.is_open()) {
		std::string line;
		while(std::getline(mapFile, line)) {
			if(inExportsSection) {
				if(line == "") {
					inExportsSection = false;
				} else {
					std::istringstream s(line);
					std::string t;
					std::string symbol;
					int state = 0;
					int address = 0;

					while(std::getline(s, t, ' ')) {
						if(t != "") {
							switch(state) {
								case 0:
									symbol = t;
									state = 1;
									break;
								case 1:
									std::istringstream(t) >> std::hex >> address;
									symbols[symbol] = address;
									state = 2;
									break;
								default:
									// skip every third string...
									state = 0;
							}
						}
					}
				}
			} else {
				if(line == "Exports list by value:") {
					inExportsSection = true;
					// Skip the next line
					std::getline(mapFile, line);
				}
			}
		}
	}

	return symbols;
}

StringArray loadExportedSymbols(const char *filename) {
	StringArray symbols;

	std::ifstream exportsFile(filename);
	if(exportsFile.is_open()) {
		std::string symbol;

		exportsFile >> symbol;
		while(!exportsFile.eof()) {
			symbols.push_back(symbol);
			exportsFile >> symbol;
		}
	}

	return symbols;
}

void writeOutput(std::ostream &output, StringArray &exports, SymbolMap &symbols) {
	int maxExportLength = 0;
	for(StringArray::const_iterator i = exports.begin(); i != exports.end(); ++i) {
		if(i->length() > maxExportLength) {
			maxExportLength = i->length();
		}
    }

	output << std::hex;

	for(StringArray::const_iterator i = exports.begin(); i != exports.end(); ++i) {
    	output << *i;
    	for(int s = i->length(); s < maxExportLength; s++) {
    		output << " ";
    	}
    	output << " := $" << symbols[*i] << std::endl;
    }

    output << std::dec;
}

int main(int argc, char** argv) {
	bool help = false;
	char* mapFilename = NULL;
    char* inputFilename = NULL;
    char* outFilename = NULL;

	static struct option options[] = {
        { "help",       no_argument,        0,  '?' },
        { "input",      required_argument,  0,  'i' },
        { "map",      	required_argument,  0,  'm' },
        { "output",     required_argument,  0,  'o' }
    };

	int option_index = 0;

    int c;
    while((c = getopt_long(argc, argv, "i:m:o:", options, &option_index)) != -1) {
        switch(c) {
            case 'i':
                inputFilename = optarg;
                break;
            case 'm':
                mapFilename = optarg;
                break;
            case 'o':
                outFilename = optarg;
                break;
            case '?':
                help = true;
                break;
        }
    }

    if(help || !mapFilename || !outFilename) {
        std::cout << "Usage: " << argv[0] << " [OPTIONS]" << std::endl;
        std::cout << std::endl;
        std::cout << "Options:" <<std::endl;
        std::cout << "  -i, --input         The name if the input file containing the symbols to put into the include file" << std::endl;
        std::cout << "  -m, --map     		The name of the map file generated by ld65 that contains the symbol addresses" << std::endl;
        std::cout << "  -o, --output    	The name of the output file; if omitted the output will be written to system out" << std::endl;
        exit(1);
    }

    SymbolMap symbols = loadSymbolMap(mapFilename);
    StringArray exports = loadExportedSymbols(inputFilename);

    bool outputWritten = false;

    if(outFilename) {
    	std::ofstream output(outFilename);
    	if(output.is_open()) {
    		writeOutput(output, exports, symbols);
    		outputWritten = true;
    	}
    }

    if(!outputWritten) {
    	writeOutput(std::cout, exports, symbols);
	}

	return 0;
}