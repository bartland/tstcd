#!/usr/bin/env bash

set -e

platform="$(uname)"
echo "$platform"

PROOT=$PWD

rm -rf build
mkdir build
cd build

DEFINES_FLAGS="-DCURL_STATICLIB -DLIBXML_STATIC -DLIBXSLT_STATIC -DNGHTTP2_STATICLIB -DXMLSEC_CRYPTO_OPENSSL -DXMLSEC_NO_CRYPTO_DYNAMIC_LOADING -DXMLSEC_NO_XSLT -DXMLSEC_STATIC"
if [[ "$platform" =~ ^MINGW* ]]; then
    PROOT_SDK=
    DEFINES_FLAGS="$DEFINES_FLAGS -D_FORTIFY_SOURCE=0 -D_MINGW -D_WIN32 -DMINGW -DWIN32"
    COMPILE_FLAGS="-I/C/msys64/mingw64/include/libxml2  -O2    -Wl,dynamicbase -Wl,nxcompat -ansi -std=c99 -pedantic-errors -Werror -Wmissing-prototypes -Wstrict-prototypes -Wall -Wextra -Wshadow -Wcast-qual -Wwrite-strings -Wformat=2 -Wstrict-overflow=5 -Waggregate-return -Wbad-function-cast -Wcast-align -Wmissing-declarations -Wnested-externs -Wredundant-decls -Winline -Wno-error=long-long -Wno-format-nonliteral -Wstack-protector --param ssp-buffer-size=4 -Wno-pedantic-ms-format -Wno-format"
    LINK_FLAGS="-O2  -Wl,--allow-multiple-definition  -Wl,-Bstatic -lcurl -lssl -lcrypto -lxml2 -ljansson -Wl,-Bdynamic -static-libgcc -lpsl -lidn2 -Wl,-Bstatic -lnghttp2 -lcrypt32 -lunistring -lssh2 -lbrotlidec-static -lbrotlicommon-static -lz -llzma -lintl -liconv -lwldap32 -lwsock32 -lws2_32 -lgdi32 -lcomdlg32 -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32"
elif [[ "$platform" =~ ^Darwin* ]]; then
    PROOT_SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk
    DEFINES_FLAGS="$DEFINES_FLAGS -D_ISO_C_VISIBLE=1999 -D_POSIX_C_SOURCE=200112 -D_POSIX_SOURCE"
    COMPILE_FLAGS="-I/usr/local/opt/openssl@1.1/include -I$PROOT_SDK/usr/include/libxml2 -I/usr/local/include  -O2  -isysroot $PROOT_SDK -mmacosx-version-min=10.11 -fstack-protector-all -ftrapv -ansi -std=c99 -pedantic-errors -Werror -Wmissing-prototypes -Wstrict-prototypes -Wall -Wextra -Wshadow -Wcast-qual -Wwrite-strings -Wformat=2 -Wstrict-overflow=5 -Waggregate-return -Wbad-function-cast -Wcast-align -Wmissing-declarations -Wnested-externs -Wredundant-decls -Winline -Wno-error=long-long -Wno-nullability-completeness -Wno-nullability-extension -Wno-expansion-to-defined -Wno-format-nonliteral -fPIC"
    LINK_FLAGS="-O2  -isysroot $PROOT_SDK -mmacosx-version-min=10.11 -Wl,-headerpad_max_install_names -Wl,-search_paths_first  /usr/lib/libcurl.dylib /usr/local/opt/openssl@1.1/lib/libssl.a /usr/local/opt/openssl@1.1/lib/libcrypto.a /usr/lib/libxml2.dylib /usr/local/lib/libjansson.a /usr/lib/libz.dylib /usr/local/lib/liblzma.a /usr/local/lib/libIDN.a /usr/lib/libiconv.dylib"
else
    printf "\n%s\n" "Unknown platform"
    exit 1
fi

echo "============================================ Building C object lib.c.o"
cc $DEFINES_FLAGS -I$PROOT/mytst/include $COMPILE_FLAGS -o lib.c.o   -c $PROOT/mytst/src/lib.c;

echo "-------------------------------------------- Building C object lib2.c.o"
cc $DEFINES_FLAGS -I$PROOT/mytst/include $COMPILE_FLAGS -o lib2.c.o   -c $PROOT/mytst/src/lib2.c

echo "-------------------------------------------- Linking C static library libmytst.a"
ar qc libmytst.a  lib.c.o lib2.c.o
ranlib libmytst.a

echo "-------------------------------------------- Linking C shared library libmytst"
[[ "$platform" =~ ^MINGW* ]] && {
    ar cr tst_objects.a  lib.c.o lib2.c.o;
    cc -Wl,--whole-archive tst_objects.a -Wl,--no-whole-archive -Wl,--export-all-symbols -shared -o libmytst.dll -Wl,--out-implib,libmytst.dll.a -Wl,--major-image-version,3,--minor-image-version,0 $LINK_FLAGS; }
[[ "$platform" =~ ^Darwin* ]] && {
    cc $LINK_FLAGS -dynamiclib -compatibility_version 3.0.0 -current_version 3.0.0 -o libmytst.3.0.0.dylib -install_name @rpath/libmytst.3.dylib lib.c.o lib2.c.o; }

[[ ! "$platform" =~ ^MINGW* ]] && { ln -s libmytst.3.0.0.dylib libmytst.3.dylib; ln -s libmytst.3.dylib libmytst.dylib; }

echo "============================================ Building C object main.c.o"
cc $DEFINES_FLAGS -I$PROOT/mytstx/include -I$PROOT/mytst/include $COMPILE_FLAGS -o main.c.o   -c $PROOT/mytstx/src/main.c

echo "-------------------------------------------- Building C object maintst.c.o"
cc $DEFINES_FLAGS -I$PROOT/mytstx/include -I$PROOT/mytst/include $COMPILE_FLAGS -o maintst.c.o   -c $PROOT/mytstx/src/maintst.c

echo "-------------------------------------------- Linking C executable mytstx"
[[ "$platform" =~ ^MINGW* ]] && {
    ar cr tstx_objects.a main.c.o maintst.c.o;
    cc -Wl,--whole-archive tstx_objects.a -Wl,--no-whole-archive -o mytstx.exe -Wl,--major-image-version,3,--minor-image-version,0  libmytst.dll.a $LINK_FLAGS; }
[[ "$platform" =~ ^Darwin* ]] && {
    cc $LINK_FLAGS main.c.o maintst.c.o  -o mytstx-3.0.0  libmytst.dylib; }

[[ ! "$platform" =~ ^MINGW* ]] && { ln -s mytstx-3.0.0 mytstx; }
[[ "$platform" =~ ^Darwin* ]] && { install_name_tool -add_rpath '.' mytstx; }

echo "============================================ Running mytstx"
echo ""

echo "********************************************"
./mytstx
echo "********************************************"
