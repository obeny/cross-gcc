#!/bin/bash
# shellcheck disable=SC1091,SC2034,SC2086,SC2329

REQUIRED_CMDS="jimsh libftdi-config"

# load framework
source ./VERSIONS
source ../common.sh
source ${ROOTDIR}/prereqs.sh

#
# CONFIG SECTION
#
ALL_DNADR+="${DNADR_PREREQ} ${GDB_DNADR} ${OPENOCD_DNADR}"

# steps definition
STEPS+="gdb openocd"

# configure options
CONF_COMMON="${CONF_PREFIX}"

#
# MAIN
#

# show introduction
function target_info()
{
    echo -e "GDB-version:\t\t ${GDB_VER}"
    echo -e "OpenOCD-version:\t ${OPENOCD_VER}"
}

function stage_mkbuilddir()
{
    mkdir -p ${BUILDDIR}/{build-gdb,build-openocd}
}

function stage_gdb()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-gdb || exit

    configure_gen "$(srcdir ${GDB_DNADR})" ${CONF_COMMON} ${CONF_GENDISABLE} --with-gmp=${PREFIX_PREREQS} --with-mpfr=${PREFIX_PREREQS} --with-mpc=${PREFIX_PREREQS} --with-isl=${PREFIX_PREREQS} --with-expat=${PREFIX_PREREQS} \
        --with-pkgversion="'${TC_BRANDING}'" --with-system-readline --with-python=/usr/bin/python --enable-languages=c,c++ --enable-multilib --enable-interwork --enable-targets=all || die "gdb configuration failed..."

    run_make || die "gdb make failed..."
    make -j1 install || die "gdb installation failed..."

    remove_bdir build-gdb || die "removing builddir failed..."
}

function stage_openocd()
{
    set_buildflags_base
    cd ${BUILDDIR}/build-openocd || exit

    configure_gen "$(srcdir ${OPENOCD_DNADR})" ${CONF_PREFIX} --enable-ftdi --enable-stlink --enable-jlink --enable-internal-jimtcl --enable-internal-libjaylink --disable-werror || die "openocd configuration failed..."

    run_make || die "openocd make failed..."
    make -j1 install || die "openocd installation failed..."

    remove_bdir build-openocd || die "removing builddir failed..."
}

run
exit
