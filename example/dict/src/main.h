
#include <errno.h>
#include <limits.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include "h2o.h"
#include "h2o/http1.h"
#include "h2o/http2.h"
//#include "h2o/memcached.h"

//#include "libpq-fe.h"
#include <unistd.h>
#include <math.h>
#include <time.h>

typedef int bool;

typedef struct {
  //h2o_iovec_t fpath;
  h2o_iovec_t buf;
  time_t updated;
} cache;
