#ifndef _def_h_
#define _def_h_

#include <stdio.h>

enum Direction {
    DIR_IN,
    DIR_OUT,
    DIR_INOUT,
};

int vhdp_parse_file(FILE *file);

#endif /*_def_h_*/