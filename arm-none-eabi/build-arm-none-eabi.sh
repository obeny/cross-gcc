#!/bin/bash

# load framework
source ../common.sh

#
# CONFIG SECTION
#

# package versions
NEWLIB_VER="4.2.0.20211231"
#NEWLIB_VER="git@git://sourceware.org/git/newlib-cygwin.git@8c87ffd372232476ac5d1705dd32ddda54134c2b@master"
GDB_VER="13.1"
OPENOCD_VER="0.12.0"
#OPENOCD_VER="git@git://git.code.sf.net/p/openocd/code@4dbcb1e79d94a113af9c3da9c6f172782515f35e@openocd"

# download addresses
NEWLIB_DNADR="ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz"
#NEWLIB_DNADR="${NEWLIB_VER}"
GDB_DNADR="http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VER}.tar.xz"
OPENOCD_DNADR="http://sourceforge.net/projects/openocd/files/openocd/${OPENOCD_VER}/openocd-${OPENOCD_VER}.tar.bz2"
#OPENOCD_DNADR="${OPENOCD_VER}"

ALL_DNADR+="$NEWLIB_DNADR $GDB_DNADR $OPENOCD_DNADR"

# steps definition
STEPS+="newlib-full newlib-nano gcc-finish-full gcc-finish-nano copy-nano gdb openocd"

# configure options
CONF_COMMON="${CONF_PRFX} --target=${TARGET} --enable-multilib --enable-interwork"

# newlibc configuration
LIBC_FULL_OPTS="--disable-newlib-supplied-syscalls --enable-newlib-io-long-long --enable-newlib-io-c99-formats --enable-newlib-reent-check-verify --enable-newlib-register-fini --enable-newlib-retargetable-locking \
    --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient --disable-newlib-unbuf-stream-opt"
LIBC_NANO_OPTS="--disable-newlib-supplied-syscalls --enable-newlib-reent-check-verify --enable-newlib-reent-small --enable-newlib-retargetable-locking --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient \
    --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt --enable-lite-exit --enable-newlib-global-atexit --enable-newlib-nano-formatted-io"

LIBC_CFLAGS="-g -fdata-sections -ffunction-sections"

# toolchain configuration
GCC_LCPP="--with-host-libstdcxx=-static-libgcc"

#
# MAIN
#
function target_info()
{
    echo -e "BINUTILS-version:\t ${BINUTILS_VER}"
    echo -e "GCC-version:\t\t ${GCC_VER}"
    echo -e "NEWLIB-version:\t\t ${NEWLIB_VER}"
    echo -e "GDB-version:\t\t ${GDB_VER}"
    echo -e "OpenOCD-version:\t ${OPENOCD_VER}"
}

function stage_mkbuilddir()
{
    mkdir -p ${BUILDDIR}/{build-binutils,build-gcc,build-libc-nano,build-libc-full,build-gcc-nano,build-gcc-full,build-gdb,build-openocd}
}

function stage_binutils()
{
    stage_binutils-generic
}

function stage_gcc()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc

    configure_gcc --enable-languages=c --with-multilib-list=rmprofile --with-sysroot=${PREFIX}/${TARGET} --with-newlib \
    --disable-libstdcxx-pch --without-headers "${GCC_LCPP}" || die "gcc configuration failed..."
    run_make all-gcc || die "gcc make failed..."
    make -j1 install-gcc || die "gcc installation failed..."

    remove_bdir build-gcc || die "removing builddir failed..."

    cd ${PREFIX}/${TARGET}
    rm -rf lib/libiberty.a
    rm -rf include
}

function stage_newlib-full()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS}"
    cd ${BUILDDIR}/build-libc-full

    configure_gen `srcdir ${NEWLIB_DNADR}` ${CONF_COMMON} ${CONF_DISLIB} ${LIBC_FULL_OPTS} --disable-shared || die "newlib-full configuration failed..."

    run_make || die "newlib-full make failed..."
    make -j1 install || die "newlib-full installation failed..."

    remove_bdir build-libc-full || die "removing builddir failed..."
}

function stage_newlib-nano()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS}"
    cd ${BUILDDIR}/build-libc-nano

    configure_gen `srcdir ${NEWLIB_DNADR}` ${CONF_COMMON} ${CONF_DISLIB} ${LIBC_NANO_OPTS} --disable-shared --prefix=${PREFIX}/nano || die "newlib-nano configuration failed..."

    run_make || die "newlib-nano make failed..."
    make -j1 install || die "newlib-nano installation failed..."

    remove_bdir build-libc-nano || die "removing builddir failed..."
}

function stage_gcc-finish-full()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc-full
    export CFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS}"
    export CXXFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS} -fno-exceptions"

    configure_gcc --with-newlib --disable-libstdcxx-pch --with-headers=yes --enable-plugins --disable-libstdcxx-verbose \
    --with-multilib-list=rmprofile --with-sysroot=${PREFIX}/${TARGET} "${GCC_LCPP}" || die "gcc-finish-full configuration failed..."

    export INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
    run_make all || die "gcc-finish-full make failed..."
    make -j1 install || die "gcc-finish-full installation failed..."
    unset INHIBIT_LIBC_CFLAGS

    remove_bdir build-gcc-full || die "removing builddir failed..."
}

function stage_gcc-finish-nano()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc-nano
    export CFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS}"
    export CXXFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS} -fno-exceptions"

    configure_gcc --with-newlib --disable-libstdcxx-pch --with-headers=yes --enable-plugins --disable-libstdcxx-verbose \
    --with-multilib-list=rmprofile --prefix=${PREFIX}/nano --with-sysroot=${PREFIX}/nano/${TARGET} "${GCC_LCPP}" || die "gcc-finish-nano configuration failed..."

    export INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
    run_make all || die "gcc-finish-nano make failed..."
    make -j1 install || die "gcc-finish-nano installation failed..."
    unset INHIBIT_LIBC_CFLAGS

    remove_bdir build-gcc-nano || die "removing builddir failed..."
}

function stage_copy-nano()
{
    MULTILIBS=$(${TARGET}-gcc -print-multi-lib)
    for MULTILIB in ${MULTILIBS}
    do
	MULTILIB=${MULTILIB%%;*}
	SRC="${PREFIX}/nano/${TARGET}/lib/${MULTILIB}"
	DST="${PREFIX}/${TARGET}/lib/${MULTILIB}"
	mkdir -p ${DST}
	cp "${SRC}/libc.a" "${DST}/libc_nano.a"
	cp "${SRC}/libg.a" "${DST}/libg_nano.a"
	cp "${SRC}/librdimon.a" "${DST}/librdimon_nano.a"
	cp "${SRC}/libstdc++.a" "${DST}/libstdc++_nano.a"
	cp "${SRC}/libsupc++.a" "${DST}/libsupc++_nano.a"
    done

    mkdir -p ${PREFIX}/${TARGET}/include/newlib-nano
    cp ${PREFIX}/nano/${TARGET}/include/newlib.h ${PREFIX}/${TARGET}/include/newlib-nano
    rm -rf ${PREFIX}/nano
}

function stage_gdb()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gdb

    configure_gen `srcdir ${GDB_DNADR}` ${CONF_COMMON} --with-libexpat --with-libexpat-prefix=${PREFIX_PREREQS} || die "gdb configuration failed..."

    run_make || die "gdb make failed..."
    make -j1 install || die "gdb installation failed..."

    remove_bdir build-gdb || die "removing builddir failed..."
}

function stage_openocd()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-openocd

    configure_gen `srcdir ${OPENOCD_DNADR}` ${CONF_PRFX} --enable-ftdi --enable-internal-jimtcl || die "openocd configuration failed..."

    run_make || die "openocd make failed..."
    make -j1 install || die "openocd installation failed..."

    remove_bdir build-openocd || die "removing builddir failed..."
}

run
exit
