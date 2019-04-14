#include "Entity.h"

#include <list>
#include <string>
#include <sstream>

#include "Port.h"

Entity::Entity(std::string *name, std::list<Port*> *ports)
{
    m_name = name;
    m_ports = ports;
}

Entity::~Entity()
{
}

std::string Entity::toString() {
    std::ostringstream oss;

    oss << "Entity: " << *m_name << std::endl;

    for(Port* p : *m_ports) {
        oss << "  " << p->toString() << std::endl;
    }

    return oss.str();
}