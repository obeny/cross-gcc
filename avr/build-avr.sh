#!/bin/bash

# load framework
source ../common.sh

#
# CONFIG SECTION
#

# package versions
#LIBC_VER="2.1.0"
LIBC_VER="git@https://github.com/avrdudes/avr-libc.git@55e8cac69935657bcd3e4d938750960c757844c3@main"
AVRDUDE_VER="7.0"

# download addresses
#LIBC_DNADR="http://download.savannah.gnu.org/releases/avr-libc/avr-libc-${LIBC_VER}.tar.bz2"
LIBC_DNADR="$LIBC_VER"
AVRDUDE_DNADR="http://download.savannah.gnu.org/releases/avrdude/avrdude-${AVRDUDE_VER}.tar.gz"

ALL_DNADR+="$LIBC_DNADR $AVRDUDE_DNADR"

# steps definition
STEPS+="avr_libc avrdude"

# configure options
CONF_COMMON="${CONF_PRFX} --target=${TARGET}"

#
# MAIN
#

# show introduction
function target_info()
{
    echo -e "BINUTILS-version:\t ${BINUTILS_VER}"
    echo -e "GCC-version:\t\t ${GCC_VER}"
    echo -e "LIBC-version:\t\t ${LIBC_VER}"
    echo -e "AVRDUDE-version:\t ${AVRDUDE_VER}"
}

function stage_mkbuilddir()
{
    mkdir -p ${BUILDDIR}/{build-binutils,build-gcc,build-libc,build-avrdude}
}

function stage_binutils()
{
    stage_binutils-generic
}

function stage_gcc()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gcc

    configure_gcc --with-avrlibc=yes --with-dwarf2 || die "gcc configuration failed..."
    run_make || die "gcc make failed..."
    make -j1 install || die "gcc installation failed..."

    remove_bdir build-gcc || die "removing builddir failed..."
}

function stage_avr_libc()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-libc

    configure_gen `srcdir ${LIBC_DNADR}` --host=avr --build=`../${SDIR}/config.guess` --with-debug-info=dwarf-2 || die "avr-libc configuration failed..."
    run_make || die "avr-libc make failed..."
    make -j1 install || die "avr-libc installation failed..."

    remove_bdir build-libc || die "removing builddir failed..."
}

function stage_avrdude()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-avrdude

    configure_gen `srcdir ${AVRDUDE_DNADR}` ${CONF_PRFX} --disable-parport || die "avrdude configuration failed..."
    run_make || die "avrdude make failed..."
    make -j1 install || die "avrdude installation failed..."

    remove_bdir build-avrdude || die "removing builddir failed..."
}

run
exit
