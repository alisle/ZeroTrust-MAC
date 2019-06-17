//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include "include/payload.h"

int create_socket(void);
payload* get_kern_message(int fd);
char* get_process_name(pid_t pid);

