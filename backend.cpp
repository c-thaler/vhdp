#include "backend.h"
#include <iostream>

void vhdp_entity(std::string *name) {
    std::cout<<"entity " << *name << std::endl;
}

void vhdp_entity_port(int direction) {
    std::cout<<"port (dir:" << direction << ")" << std::endl;
}

void vhdp_arch() {
    std::cout<<"arch\n";
}