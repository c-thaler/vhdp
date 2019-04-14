#ifndef _port_h_
#define _port_h_

#include <string>

#include "bison_def.h"

class Port
{
private:
    std::string *m_name;
    std::string *m_type;
    Direction m_direction;

public:
    Port(std::string *name, Direction direction, std::string *type);
    ~Port();

    std::string toString();
};

#endif /* _port_h_ */