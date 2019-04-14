#ifndef _entity_h_
#define _entity_h_

#include <list>
#include <string>

#include "Port.h"

class Entity
{
private:
    std::string *m_name;
    std::list<Port*> *m_ports;
    
public:
    Entity(std::string *name, std::list<Port*> *ports);
    ~Entity();

    std::string toString();
};

#endif /* _entity_h_ */
