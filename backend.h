#ifndef _backend_h_
#define _backend_h_

#include <string>

void vhdp_entity(std::string *name);
void vhdp_entity_port(int direction);
void vhdp_arch(std::string *arch_name, std::string *entity_name);

#endif /*_backend_h_*/