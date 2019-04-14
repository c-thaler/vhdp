#include "Port.h"

#include <string>
#include <iostream>

Port::Port(std::string *name, Direction direction, std::string *type) {
    m_name = name;
    m_type = type;
    m_direction = direction;
}

Port::~Port() {
}

std::string Port::toString() {
    std::string dir;

    switch(m_direction) {
        case DIR_IN:
            dir = "->";
            break;
        case DIR_OUT:
            dir = "<-";
            break;
        case DIR_INOUT:
            dir = "<>";
            break;
    }

    return dir + " " + *m_name + " : " + *m_type;
}