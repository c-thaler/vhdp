#ifndef _arch_h_
#define _arch_h_

#include <list>
#include <string>

class Arch
{
private:
    std::string *m_arch_name;
    std::string *m_entity_name;
    
public:
    Arch(std::string *arch_name, std::string *entity_name);
    ~Arch();

    std::string toString();
};

#endif /* _arch_h_ */
