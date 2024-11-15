#!/bin/bash
# shellcheck disable=SC1091,SC2086,SC2329

# load framework
source ../common.sh

#
# CONFIG SECTION
#

# package versions
#NEWLIB_VER="4.3.0.20230120"
NEWLIB_VER="git@git://sourceware.org/git/newlib-cygwin.git@6af8fea4bbad6678ad6ef82b00860877a01c3614@main" #4.4.0+, 2024-10-13
GDB_VER="15.2"
#OPENOCD_VER="0.12.0"
OPENOCD_VER="git@https://github.com/obeny/openocd.git@ae71ddd58a16af1c5c7ab2ab3d3a990fe98d4cab@master-custom" #0.12+, 2024-10-23

# download addresses
#NEWLIB_DNADR="ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz"
NEWLIB_DNADR="${NEWLIB_VER}"
GDB_DNADR="http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VER}.tar.xz"
#OPENOCD_DNADR="http://sourceforge.net/projects/openocd/files/openocd/${OPENOCD_VER}/openocd-${OPENOCD_VER}.tar.bz2"
OPENOCD_DNADR="${OPENOCD_VER}"

ALL_DNADR+="${NEWLIB_DNADR} ${GDB_DNADR} ${OPENOCD_DNADR}"

# steps definition
STEPS+="newlib-patch newlib-full newlib-nano gcc-finish-full gcc-finish-nano copy-nano gdb openocd"

# configure options
CONF_COMMON="${CONF_PREFIX} --target=${TARGET} --enable-multilib --enable-interwork"

# newlibc configuration
LIBC_COMMON_OPTS="--disable-newlib-supplied-syscalls --enable-newlib-reent-check-verify --enable-newlib-retargetable-locking \
    --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient"

LIBC_FULL_OPTS="${LIBC_COMMON_OPTS} --enable-newlib-io-long-long --enable-newlib-io-c99-formats --enable-newlib-register-fini \
    --disable-newlib-unbuf-stream-opt"
LIBC_NANO_OPTS="${LIBC_COMMON_OPTS} --enable-newlib-reent-small --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt \
    --enable-lite-exit --enable-newlib-global-atexit --enable-newlib-nano-formatted-io"

LIBC_CFLAGS="-g -fdata-sections -ffunction-sections -pipe"

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
    stage_binutils_generic
}

function stage_gcc()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc || exit

    configure_gcc --enable-languages=c --with-multilib-list=rmprofile --with-sysroot=${PREFIX}/${TARGET} --with-newlib \
    --without-headers || die "gcc configuration failed..."
    run_make all-gcc || die "gcc make failed..."
    make -j1 install-gcc || die "gcc installation failed..."

    remove_bdir build-gcc || die "removing builddir failed..."

    cd ${PREFIX}/${TARGET} || exit
}

function stage_newlib-patch()
{
    cd "$(srcdir "${NEWLIB_DNADR}")" || exit
    do_patch ${ROOTDIR}/_patches/newlib-unwind.patch 1
}

function stage_newlib-full()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS}"
    export CXXFAGS_FOR_TARGET="${CFLAGS_FOR_TARGET}"
    cd ${BUILDDIR}/build-libc-full || exit

    configure_gen "$(srcdir ${NEWLIB_DNADR})" ${CONF_COMMON} ${CONF_DISLIB} ${LIBC_FULL_OPTS} || die "newlib-full configuration failed..."

    run_make || die "newlib-full make failed..."
    make -j1 install || die "newlib-full installation failed..."

    remove_bdir build-libc-full || die "removing builddir failed..."
}

function stage_newlib-nano()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS}"
    export CXXFAGS_FOR_TARGET="${CFLAGS_FOR_TARGET}"
    cd ${BUILDDIR}/build-libc-nano || exit

    configure_gen "$(srcdir ${NEWLIB_DNADR})" ${CONF_COMMON} ${CONF_DISLIB} ${LIBC_NANO_OPTS} --prefix=${PREFIX}/nano || die "newlib-nano configuration failed..."

    run_make || die "newlib-nano make failed..."
    make -j1 install || die "newlib-nano installation failed..."

    remove_bdir build-libc-nano || die "removing builddir failed..."
}

function stage_gcc-finish-full()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc-full || exit
    export CFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS}"
    export CXXFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS} -fno-exceptions"

    configure_gcc --with-newlib --with-headers=yes --enable-plugins \
    --with-multilib-list=rmprofile --with-sysroot=${PREFIX}/${TARGET} || die "gcc-finish-full configuration failed..."

    export INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
    run_make all || die "gcc-finish-full make failed..."
    make -j1 install || die "gcc-finish-full installation failed..."
    unset INHIBIT_LIBC_CFLAGS

    remove_bdir build-gcc-full || die "removing builddir failed..."
}

function stage_gcc-finish-nano()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc-nano || exit
    export CFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS}"
    export CXXFLAGS_FOR_TARGET="-Os ${LIBC_CFLAGS} -fno-exceptions"

    configure_gcc --with-newlib --with-headers=yes --enable-plugins \
    --with-multilib-list=rmprofile --prefix=${PREFIX}/nano --with-sysroot=${PREFIX}/nano/${TARGET} || die "gcc-finish-nano configuration failed..."

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
    cd ${BUILDDIR}/build-gdb || exit

    configure_gen "$(srcdir ${GDB_DNADR})" ${CONF_COMMON} --with-gmp=${PREFIX_PREREQS} --with-mpfr=${PREFIX_PREREQS} --with-mpc=${PREFIX_PREREQS} --with-isl=${PREFIX_PREREQS} || die "gdb configuration failed..."

    run_make || die "gdb make failed..."
    make -j1 install || die "gdb installation failed..."

    remove_bdir build-gdb || die "removing builddir failed..."
}

function stage_openocd()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-openocd || exit

    configure_gen "$(srcdir ${OPENOCD_DNADR})" ${CONF_PREFIX} --enable-ftdi --enable-stlink --enable-jlink --enable-internal-jimtcl --enable-internal-libjaylink || die "openocd configuration failed..."

    run_make || die "openocd make failed..."
    make -j1 install || die "openocd installation failed..."

    remove_bdir build-openocd || die "removing builddir failed..."
}

run
exit
