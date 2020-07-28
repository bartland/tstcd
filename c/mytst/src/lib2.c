#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <stdarg.h>

#include "curl/curl.h"
#include "jansson.h"

#include "mytst/lib.h"
#include "mytst/lib2.h"

/*********************************************************************************/
int tst_init2(const char *str) {
    printf("\nhello from tst_init2\n");
    return tst_init(str);
}
