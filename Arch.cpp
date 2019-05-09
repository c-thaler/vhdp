#include "Arch.h"

#include <string>
#include <sstream>

#include "Port.h"

Arch::Arch(std::string *arch_name, std::string *entity_name)
{
    m_arch_name = arch_name;
    m_entity_name = entity_name;
}

Arch::~Arch()
{
}

std::string Arch::toString() {
    std::ostringstream oss;

    oss << "Arch: " << *m_arch_name << " of " << *m_entity_name << std::endl;

    return oss.str();
}