#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <stdarg.h>

#include "curl/curl.h"
#include "jansson.h"

#include "mytst/lib.h"

/*********************************************************************************/
int tst_init(const char *str) {
    printf("\nhello from tst_init: curl version: %s [%s]\n", curl_version(), str?str:"");
    json_equal(NULL, NULL);
    return 0;
}
