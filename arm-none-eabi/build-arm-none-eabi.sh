#!/bin/bash
# shellcheck disable=SC1091,SC2034,SC2086,SC2329

# load framework
source ./VERSIONS
source ../common.sh
source ${ROOTDIR}/prereqs.sh

#
# CONFIG SECTION
#
ALL_DNADR+="${DNADR_PREREQ} ${BINUTILS_DNADR} ${GCC_DNADR} ${NEWLIB_DNADR}"

# steps definition
STEPS+="binutils gcc newlib-full newlib-nano gcc-finish-full gcc-finish-nano copy-nano"

# configure options
CONF_TARGET_COMMON="${CONF_PREFIX} --target=${TARGET} --enable-multilib --enable-interwork"

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

# show info
function target_info()
{
    echo -e "BINUTILS-version:\t ${BINUTILS_VER}"
    echo -e "GCC-version:\t\t ${GCC_VER}"
    echo -e "NEWLIB-version:\t\t ${NEWLIB_VER}"
}

function stage_mkbuilddir()
{
    mkdir -p ${BUILDDIR}/{build-binutils,build-gcc,build-libc-nano,build-libc-full,build-gcc-nano,build-gcc-full}
}

function stage_binutils()
{
    stage_binutils_generic
}

function stage_gcc()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc || exit

    configure_gcc --enable-languages=c --with-multilib-list=rmprofile --with-sysroot=${PREFIX}/${TARGET} \
        --with-newlib --without-headers || die "gcc configuration failed..."
    run_make all-gcc || die "gcc make failed..."
    make -j1 install-gcc || die "gcc installation failed..."

    remove_bdir build-gcc || die "removing builddir failed..."

    cd ${PREFIX}/${TARGET} || exit
}

function stage_newlib-full()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-O2 ${LIBC_CFLAGS}"
    export CXXFAGS_FOR_TARGET="${CFLAGS_FOR_TARGET}"
    cd ${BUILDDIR}/build-libc-full || exit

    configure_gen "$(srcdir ${NEWLIB_DNADR})" ${CONF_TARGET_COMMON} ${CONF_DISLIB} ${LIBC_FULL_OPTS} || die "newlib-full configuration failed..."

    run_make || die "newlib-full make failed..."
    make -j1 install || die "newlib-full installation failed..."

    remove_bdir build-libc-full || die "removing builddir failed..."
}

function stage_newlib-nano()
{
    clear_buildflags
    export CFLAGS_FOR_TARGET="-g -Os ${LIBC_CFLAGS}"
    export CXXFAGS_FOR_TARGET="${CFLAGS_FOR_TARGET} -fno-exceptions"
    cd ${BUILDDIR}/build-libc-nano || exit

    configure_gen "$(srcdir ${NEWLIB_DNADR})" ${CONF_TARGET_COMMON} ${CONF_DISLIB} ${LIBC_NANO_OPTS} --prefix=${PREFIX}/nano || die "newlib-nano configuration failed..."

    run_make || die "newlib-nano make failed..."
    make -j1 install || die "newlib-nano installation failed..."

    remove_bdir build-libc-nano || die "removing builddir failed..."
}

function stage_gcc-finish-full()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc-full || exit
    export CFLAGS_FOR_TARGET="-g -O2 ${LIBC_CFLAGS}"
    export CXXFLAGS_FOR_TARGET="-g -O2 ${LIBC_CFLAGS}"

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

run
exit
