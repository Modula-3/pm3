#include "wrap.h"
#include <sys/types.h>
#include <sys/socket.h>

int
m3_connect(int s, const struct sockaddr *name, int namelen)
{
  int result;

  ENTER_CRITICAL;
  MAKE_READABLE(name);
  result = connect(s, name, namelen);
  EXIT_CRITICAL;
  return result;
}
