#!/usr/bin/env bash

set -e

PROOT=$PWD

rm -rf build
mkdir build
cd build

DEFINES_FLAGS="-DCURL_STATICLIB -DLIBXML_STATIC -DLIBXSLT_STATIC -DMINGW -DNGHTTP2_STATICLIB -DWIN32 -DXMLSEC_CRYPTO_OPENSSL -DXMLSEC_NO_CRYPTO_DYNAMIC_LOADING -DXMLSEC_NO_XSLT -DXMLSEC_STATIC -D_FORTIFY_SOURCE=0 -D_MINGW -D_WIN32"
COMPILE_FLAGS="-I/C/msys64/mingw64/include/libxml2  -O2    -Wl,dynamicbase -Wl,nxcompat -ansi -std=c99 -pedantic-errors -Werror -Wmissing-prototypes -Wstrict-prototypes -Wall -Wextra -Wshadow -Wcast-qual -Wwrite-strings -Wformat=2 -Wstrict-overflow=5 -Waggregate-return -Wbad-function-cast -Wcast-align -Wmissing-declarations -Wnested-externs -Wredundant-decls -Winline -Wno-error=long-long -Wno-format-nonliteral -Wstack-protector --param ssp-buffer-size=4 -Wno-pedantic-ms-format -Wno-format"
LINK_FLAGS="-O2  -Wl,--allow-multiple-definition  -Wl,-Bstatic -lcurl -lssl -lcrypto -lxml2 -ljansson -Wl,-Bdynamic -static-libgcc -lpsl -lidn2 -Wl,-Bstatic -lnghttp2 -lcrypt32 -lunistring -lssh2 -lbrotlidec-static -lbrotlicommon-static -lz -llzma -lintl -liconv -lwldap32 -lwsock32 -lws2_32 -lgdi32 -lcomdlg32 -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32"

echo "============================================"
echo "Building C object lib.c.o"
gcc $DEFINES_FLAGS -I$PROOT/mytst/include $COMPILE_FLAGS -o lib.c.o   -c $PROOT/mytst/src/lib.c

echo "--------------------------------------------"
echo "Building C object lib2.c.o"
gcc $DEFINES_FLAGS -I$PROOT/mytst/include $COMPILE_FLAGS -o lib2.c.o   -c $PROOT/mytst/src/lib2.c

echo "Built target mytst_obj"

echo "--------------------------------------------"
echo "Linking C static library libmytst.a"

ar qc libmytst.a  lib.c.o lib2.c.o
ranlib libmytst.a

echo "Built target mytst.a"

echo "--------------------------------------------"
echo "Linking C shared library libmytst.dll"

ar cr tst_objects.a  lib.c.o lib2.c.o

gcc \
-Wl,--whole-archive tst_objects.a -Wl,--no-whole-archive -Wl,--export-all-symbols -shared \
-o libmytst.dll -Wl,--out-implib,libmytst.dll.a -Wl,--major-image-version,3,--minor-image-version,0 \
$LINK_FLAGS

echo "Built target mytst"

echo "============================================"
echo "Building C object main.c.o"

gcc $DEFINES_FLAGS -I$PROOT/mytstx/include -I$PROOT/mytst/include $COMPILE_FLAGS -o main.c.o   -c $PROOT/mytstx/src/main.c

echo "--------------------------------------------"
echo "Building C object maintst.c.o"

gcc $DEFINES_FLAGS -I$PROOT/mytstx/include -I$PROOT/mytst/include $COMPILE_FLAGS -o maintst.c.o   -c $PROOT/mytstx/src/maintst.c

echo "--------------------------------------------"
echo "Linking C executable mytstx.exe"

ar cr tstx_objects.a main.c.o maintst.c.o

gcc \
-Wl,--whole-archive tstx_objects.a -Wl,--no-whole-archive \
-o mytstx.exe -Wl,--major-image-version,3,--minor-image-version,0  libmytst.dll.a \
$LINK_FLAGS

echo "Built target mytstx"

echo "============================================"
echo "Running mytstx"
./mytstx
