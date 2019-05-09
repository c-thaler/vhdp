#include "backend.h"
#include <iostream>

void vhdp_entity(std::string *name) {
    std::cout<<"entity " << *name << std::endl;
}

void vhdp_entity_port(int direction) {
    std::cout<<"port (dir:" << direction << ")" << std::endl;
}

void vhdp_arch(std::string *arch_name, std::string *entity_name) {
    std::cout<<"arch " << *arch_name << " of " << *entity_name << std::endl;
}