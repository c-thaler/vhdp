#include <stdio.h>
#include <unistd.h>
#include <iostream>

#include "bison_def.h"

void print_help(char* name) {
	fprintf(stderr, "\nUsage:\t%s { [-h] file }\n"
					"\t-h      : show this help\n"
					"\tfile  : length of data in bytes to act upon, starting at address\n",
					name);
}

int main(int argc, char *argv[]) {
    FILE *file;
    char *filename;
    int c;

    while ((c = getopt (argc, argv, "h")) != -1) {
		switch(c) {
			case 'h':
				print_help(argv[0]);
                goto end;
				break;
			case '?':
				goto fail;
				break;
			default:
				abort();
		}
	}

    if(optind < argc) {
        filename = argv[optind++];
    }
    else {
		fprintf(stderr, "%s: File name is required.\n", argv[0]);
		goto fail;
	}

    // Open a file handle to a particular file:
    file = fopen(filename, "r");

    // Make sure it is valid:
    if (!file) {
        std::cerr << "Could not open " << filename << std::endl;
        return -1;
    }

    vhdp_parse_file(file);

end:
    return 0;

fail:
    print_help(argv[0]);
    return -1;
}