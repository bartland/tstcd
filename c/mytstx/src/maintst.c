#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <stdarg.h>

#include "mytst/lib.h"
#include "mytst/lib2.h"
#include "maintst.h"

int init(const char *str) {
    return tst_init(str) + tst_init2(str);
}
