STEPS_PREREQ="pr_mkbuilddirs pr_zlib pr_gmp pr_mpfr pr_mpc pr_isl pr_expat pr_elfutils"
ALL_DNADR="$ZLIB_DNADR $GMP_DNADR $MPFR_DNADR $MPC_DNADR $ISL_DNADR $EXPAT_DNADR $ELFUTILS_DNADR "

CFLAGS_PREREQ="-O2 -pipe -g0 -w -ffunction-sections -fdata-sections"
LDFLAGS_PREREQ="-Wl,-O1"

function prereq_set_buildflags()
{
    export CFLAGS="${CFLAGS_PREREQ}"
    export CXXFLAGS="${CFLAGS}"
    export CPPFLAGS="${CFLAGS}"
    export LDFLAGS="${LDFLAGS_PREREQ}"
    export CPPFLAGS=""
}

function prereq_info()
{
    echo -e "PREREQUIREMENTS INFO:"
    echo -e "ZLIB:\t\t\t ${ZLIB_VER}"
    echo -e "GMP:\t\t\t ${GMP_VER}"
    echo -e "MPFR:\t\t\t ${MPFR_VER}"
    echo -e "MPC:\t\t\t ${MPC_VER}"
    echo -e "ISL:\t\t\t ${ISL_VER}"
    echo -e "EXPAT:\t\t\t ${EXPAT_VER}"
    echo -e "ELFUTILS:\t\t ${ELFUTILS_VER}"
}

function stage_pr_mkbuilddirs()
{
    mkdir -p ${BUILDDIR}/build-{zlib,gmp,mpfr,mpc,isl,expat,elfutils}
}

function stage_pr_zlib()
{
    print_info "BUILDING prerequisite: zlib"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-zlib

    configure_gen `srcdir ${ZLIB_DNADR}` --prefix=${PREFIX_PREREQS} --static || die "prerequisite zlib configuration failed..."
    run_make || die "prerequisite zlib make failed..."
    make -j1 install || die "prerequisite zlib installation failed..."

    remove_bdir build-zlib || die "removing zlib builddir failed..."
}

function stage_pr_gmp()
{
    print_info "BUILDING prerequisite: gmp"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-gmp

    configure_gen `srcdir ${GMP_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --enable-static --enable-cxx --disable-shared --without-readline || die "prerequisite gmp configuration failed..."
    run_make || die "prerequisite gmp make failed..."
    make -j1 install || die "prerequisite gmp installation failed..."

    remove_bdir build-gmp || die "removing gmp builddir failed..."
}

function stage_pr_mpfr()
{
    cd `srcdir ${MPFR_DNADR}`
    do_patch ${ROOTDIR}/_patches/mpfr-4.2.0-p12.patch 1

    print_info "BUILDING prerequisite: mpfr"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-mpfr

    configure_gen `srcdir ${MPFR_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --target=${TARGET} --enable-static --disable-shared --disable-nls --with-gmp=${PREFIX_PREREQS} || die "prerequisite mpfr configuration failed..."
    run_make || die "prerequisite mpfr make failed..."
    make -j1 install || die "prerequisite mpfr installation failed..."

    remove_bdir build-mpfr || die "removing mpfr builddir failed..."
}

function stage_pr_mpc()
{
    print_info "BUILDING prerequisite: mpc"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-mpc

    configure_gen `srcdir ${MPC_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --target=${TARGET} --enable-static --disable-shared --disable-nls --with-gmp=${PREFIX_PREREQS} --with-mpfr=${PREFIX_PREREQS} || die "prerequisite mpc configuration failed..."
    run_make || die "prerequisite mpc make failed..."
    make -j1 install || die "prerequisite mpc installation failed..."

    remove_bdir build-mpc || die "removing mpc builddir failed..."
}

function stage_pr_isl()
{
    print_info "BUILDING prerequisite: isl"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-isl

    configure_gen `srcdir ${ISL_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --target=${TARGET} --enable-static --disable-shared --disable-nls --with-gmp-prefix=${PREFIX_PREREQS} || die "prerequisite isl configuration failed..."
    run_make || die "prerequisite isl make failed..."
    make -j1 install || die "prerequisite isl installation failed..."

    remove_bdir build-isl || die "removing isl builddir failed..."
}

function stage_pr_expat()
{
    print_info "BUILDING prerequisite: expat"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-expat

    configure_gen `srcdir ${EXPAT_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --target=${TARGET} --enable-static --disable-shared --disable-nls || die "prerequisite expat configuration failed..."
    run_make || die "prerequisite expat make failed..."
    make -j1 install || die "prerequisite expat installation failed..."

    remove_bdir build-expat || die "removing expat builddir failed..."
}

function stage_pr_elfutils()
{
    print_info "BUILDING prerequisite: elfutils"
    prereq_set_buildflags
    cd ${BUILDDIR}/build-elfutils

    configure_gen `srcdir ${ELFUTILS_DNADR}` --prefix=${PREFIX_PREREQS} --host=${HOST} --target=${TARGET} --enable-static --disable-shared --disable-nls --disable-debuginfod --without-bzlib --without-lzma --without-zstd || die "prerequisite elfutils configuration failed..."
    run_make || die "prerequisite elfutils make failed..."
    make -j1 install || die "prerequisite elfutils installation failed..."

    remove_bdir build-elfutils || die "removing elfutils builddir failed..."
}
