#!/bin/bash
# shellcheck disable=SC1091,SC2001,SC2034,SC2086,SC2155

if [ -z "${BASH_VERSION}" ]; then
    echo "Script have to be run in BASH!"
    exit 1
fi

# die if any error occured or variable is unset
set -e
set -u
#set -x

#
# GENERIC STAGE FUNCTIONS
#

stage_download()
{
    print_info "Downloading..."

    for DWN in ${ALL_DNADR}
    do
        download "${DWN}"
    done
}

stage_unpack()
{
    print_info "Extracting..."

    for EXT in ${ALL_DNADR}
    do
        extract "${EXT}"
    done
}

stage_patch()
{
    # common
    if [ -e "${ROOTDIR}/patches/common" ]
    then
        print_info "Patching common packages..."
        for PKG in "${ROOTDIR}"/patches/common/*
        do
            PKG_BASE=$(basename "${PKG}")
            cd "${BUILDDIR}/${PKG_BASE}"
            print_info "package: ${PKG_BASE}"
            for PATCH in "${ROOTDIR}"/patches/common/"${PKG_BASE}"/*
            do
                PATCH_BASE=$(basename "${PATCH}")
                do_patch "${ROOTDIR}/patches/common/${PKG_BASE}/${PATCH_BASE}" 1
            done
        done
    fi

    # target
    if [ -e "${ROOTDIR}/patches/${TARGET}" ]
    then
        print_info "Patching target: ${TARGET} packages..."
        for PKG in "${ROOTDIR}"/patches/"${TARGET}"/*
        do
            PKG_BASE=$(basename "${PKG}")
            cd "${BUILDDIR}/${PKG_BASE}"
            print_info "package: ${PKG_BASE}"
            for PATCH in "${ROOTDIR}"/patches/"${TARGET}"/"${PKG_BASE}"/*
            do
                PATCH_BASE=$(basename "${PATCH}")
                do_patch "${ROOTDIR}/patches/${TARGET}/${PKG_BASE}/${PATCH_BASE}" 1
            done
        done
    fi

    cd "${BUILDDIR}"
}

stage_bootstrap()
{
    print_info "Bootstrapping..."

    for BSTRAP in ${ALL_DNADR}
    do
        PKGNAME=$(echo "${BSTRAP}" | cut -f 1 -d %)
        URLPROTO=$(urlproto $BSTRAP)
        PROTO="$(echo "${URLPROTO}" | cut -f 1 -d ' ')"

        case "${PROTO}" in
        git)
            print_info "Checking for bootstrap script"
            cd "${PKGNAME}" || exit
            BOOTSTRAP_SCR="$(find . -maxdepth 1 -name '*bootstrap*')"
            if [ -n "${BOOTSTRAP_SCR}" ]; then
                print_info "Running bootstrap: ${PKGNAME} ${BOOTSTRAP_SCR}"
               ./${BOOTSTRAP_SCR} || exit
               print_info "Bootstrap finished"
            else
                print_info "No bootstrap found, skipping"
            fi
            cd ..
            ;;
        *)
            ;;
        esac
    done
}

#
# HELPER FUNCTIONS
#

# -----------------------------------------
abspath()
{
    readlink -f "${1}"
}

# -----------------------------------------
die()
{
    echo "!!! ${1}"
    exit 1
}

# -----------------------------------------
do_patch()
{
    local PFILE="${1}"
    local PLEVEL="${2}"

    if [ -z "${PLEVEL}" ]; then
        patch -p0 < "${PFILE}" || die "patching: ${PFILE} failed"
    else
        patch -p"${PLEVEL}" < "${PFILE}" || die "patching: ${PFILE} failed"
    fi
}

# -----------------------------------------
remove_bdir()
{
    cd "${BUILDDIR}"
    rm -rf "${1}"
}

# -----------------------------------------
run_make()
{
    make ${MAKEOPTS} "$@"
}

# -----------------------------------------
urlproto()
{
    local DPATH="$(echo "${1}" | cut -f 2 -d '%')"
    local PROTO=""
    if echo "${DPATH}" | cut -f 2 -d ';' | grep -q '@'; then
        PROTO="$(echo ${DPATH} | cut -f 1 -d '@') $(echo ${DPATH} | cut -f 2- -d '@')"
    else
        PROTO="web ${DPATH}"
    fi

    echo "${PROTO}"
}

# -----------------------------------------
srcdir()
{
    local DNLPATH="${1}"
    local DIR="$(echo "${DNLPATH}" | cut -f 1 -d '%')"
    echo "${DIR}"
}

# -----------------------------------------
download()
{
    local DNLPATH="${1}"
    local URLPROTO="$(urlproto "${DNLPATH}")"
    URLPROTO=$(urlproto $DNLPATH)
    local PROTO="$(echo "${URLPROTO}" | cut -f 1 -d ' ')"
    local URL="$(echo "${URLPROTO}" | cut -f 2 -d ' ')"

    case "${PROTO}" in
    git)
        download_git "${DNLPATH}"
        ;;
    *)
        download_web "${URL}"
        ;;
    esac
}

# -----------------------------------------
download_web()
{
    local FILE="$(basename "${1}")"
    local URL="${1}"
    FILE=${FILE%%;*}
    URL=${URL%%;*}
    if [ ! -e "${FILE}" ]; then
        print_uinfo "downloading: ${FILE}"
        wget --no-check-certificate "${URL}" || die "download failed: ${FILE}"
    else
        print_info "file already exists: ${FILE}"
    fi
}

# -----------------------------------------
download_git()
{
    local URL="${1}"
    local GIT_DIR="$(echo "${URL}"  | cut -f 1 -d '%')"
    local GIT_URL="$(echo "${URL}"  | cut -f 2 -d '%' | cut -f 2 -d '@')"
    local GIT_HASH="$(echo "${URL}" | cut -f 2 -d '%' | cut -f 3 -d '@')"

    if [ ! -d "${GIT_DIR}" ]; then
        print_info "GIT: ${GIT_URL} -> ${GIT_DIR}; hash: ${GIT_HASH}"
        mkdir "${GIT_DIR}" && cd "${GIT_DIR}" || exit
        git init
        git remote add origin "${GIT_URL}"
        git fetch --depth=1 origin "${GIT_HASH}"

        git checkout "${GIT_HASH}"

        # handle submodules
        if [ -e ".gitmodules" ]; then
            print_info "Running submodule update"
            git submodule update --init --recursive
        else
            print_info "No gitmodules found, skipping"
        fi
        cd ..
    else
        print_info "GIT dir already exists: ${GIT_DIR}"
    fi
}

# -----------------------------------------
exec_stage()
{
    if [ ! -e stage_${1} ]; then
        print_stepinfo "running stage: ${1}"
        stage_${1} || die "couldn't execute: stage_${1}"
        print_info "stage: ${1} completed successfully"

        cd "${BUILDDIR}" || exit
        touch stage_${1}
        env > stage_${1}.env
    else
        print_info " stage: ${1} already completed: skipping it..."
    fi
}

# -----------------------------------------
extract()
{
    local DNLPATH="${1}"
    local URLPROTO="$(urlproto "${DNLPATH}")"
    URLPROTO=$(urlproto $DNLPATH)
    local PROTO="$(echo "${URLPROTO}" | cut -f 1 -d ' ')"

    case "${PROTO}" in
    git)
        local GIT_DIR="$(echo "${DNLPATH}" | cut -f 1 -d '%')"
        print_uinfo "extracting: nothing to unpack ${GIT_DIR}"
        ;;
    *)
        local SRC_DIR="$(echo "${DNLPATH}" | cut -f 1 -d '%')"
        local SRC_FILE="$(basename ${DNLPATH})"
        if [ ! -e "${SRC_DIR}" ]; then
            print_uinfo "extracting: ${SRC_FILE}"
            mkdir "${SRC_DIR}"
            tar xf "${SRC_FILE}" -C "${SRC_DIR}" --strip-components=1 || die "extraction failed: ${SRC_FILE}"
        else
            print_info "source already exists: ${SRC_DIR}"
        fi
        ;;
    esac
}

# -----------------------------------------
print_info()
{
    echo "iii ${1}"
}

# -----------------------------------------
print_details()
{
    echo "----- Entering: '${1}' -----"
    echo " running: '${2}'"
}

# -----------------------------------------
print_stepinfo()
{
    echo "*** ${1}"
}

# -----------------------------------------
print_uinfo()
{
    echo ">>> ${1}"
}

# -----------------------------------------
run()
{
    echo -e "BUILDING TOOLCHAIN FOR: ${TARGET}\n"
    echo -e "PATH:\t\t\t ${PATH}\n"
    echo -e "PREFIX:\t\t\t ${PREFIX}"
    echo -e "BUILDDIR:\t\t ${BUILDDIR}\n"
    echo -e "MAKE JOBS:\t\t ${JOBS}\n"
    show_info
    echo

    # create build directory
    [[ ! -e ${BUILDDIR} ]] && mkdir -p ${BUILDDIR}
    cd ${BUILDDIR}

    ALL_STEPS="${STEPS_GEN} ${STEPS_PREREQ} ${STEPS}"
    print_uinfo "script will perform following steps: ${ALL_STEPS}"
    echo "press RETURN key to continue..."
    read -r
    for STEP in ${ALL_STEPS}
    do
        exec_stage ${STEP}
    done

    # do the cleanup
    rm -rf ${PREFIX}/share/{doc,info,locale,man}
    rm -rf ${PREFIX}/prereqs

    echo ">>> ALL FINISHED <<<"
    read -r
}

# -----------------------------------------
show_info()
{
    prereq_info
    echo
    target_info
    echo
    echo "press RETURN key to continue..."
    read -r
}

# -----------------------------------------
set_buildflags_base()
{
    export CFLAGS="${BASE_CFLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${BASE_LDFLAGS}"
    export CPPFLAGS="${BASE_CPPFLAGS}"
}

# -----------------------------------------
clear_buildflags()
{
    unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

# -----------------------------------------
cmake_gen()
{
    DIR="${1}"
    shift

    ARGS="${CMAKE_BASE} $*"
    print_details "${DIR}" "cmake ${ARGS}"

    cmake ${ARGS} ../${DIR}
}

# -----------------------------------------
configure_gen()
{
    DIR="${1}"
    shift

    ARGS="${CONF_PREFIX} $*"
    print_details "${DIR}" "configure ${ARGS}"

    ../${DIR}/configure ${ARGS}
}

# -----------------------------------------
configure_prereq()
{
    DIR="${1}"
    shift

    ARGS="${CONF_PREFIX_PREREQS} $*"
    print_details "${DIR}" "configure ${ARGS}"

    ../${DIR}/configure ${ARGS}
}

# -----------------------------------------
configure_binutils()
{
    ARGS="${CONF_COMMON} ${CONF_GENOPTS} ${CONF_GNU} ${CONF_RELEASE} ${CONF_DISLIB} ${CONF_GENDISABLE} --with-sysroot=${PREFIX}/${TARGET} --with-system-zlib --with-zstd --enable-plugins $*"
    print_details "binutils" "configure ${ARGS}"

    SDIR="$(srcdir ${BINUTILS_DNADR})"
    ../${SDIR}/configure ${ARGS}
}

# -----------------------------------------
configure_gcc()
{
    ARGS="${CONF_COMMON} ${CONF_GENOPTS} ${CONF_GENOPTSGCC} ${CONF_GNU} ${CONF_RELEASE} ${CONF_DISLIB} ${CONF_GENDISABLE} --enable-languages=${CONF_LANG} $*"
    print_details "gcc" "configure ${ARGS}"

    SDIR="$(srcdir "${GCC_DNADR}")"
    ../${SDIR}/configure ${ARGS}
}

# -----------------------------------------
stage_binutils_generic()
{
    cd ${BUILDDIR}/build-binutils
    set_buildflags_base

    configure_binutils "" || die "binutils configuration failed..."
    run_make "" || die "binutils make failed..."
    make -j1 install || die "binutils installation failed..."

    remove_bdir build-binutils || die "removing builddir failed..."
}

# generic environment configuration
CURDIR="$(pwd)"
ROOTDIR="$(readlink -f ${CURDIR}/..)"
HOST=$(gcc -dumpmachine)
TARGET=$(basename "${CURDIR}")
BUILD_PREFIX="${BUILD_PREFIX:-}"
if [ -z "${BUILD_PREFIX}" ]; then
    PREFIX=$(abspath ${CURDIR}/../tc_${TARGET})
else
    PREFIX=${BUILD_PREFIX}/tc_${TARGET}
fi
PREFIX_PREREQS=${PREFIX}/prereqs
PATH="${PREFIX}/bin:${PATH}"
BUILDDIR=${BUILDDIR:-/tmp/tc_${TARGET}-build}
JOBS=$(nproc)
MAKEOPTS="-s -j${JOBS}"

BASE_CFLAGS="-O2 -pipe -g0 -ffunction-sections -fdata-sections -s -Wno-error -w"
BASE_LDFLAGS="-O1"
BASE_CXXFLAGS="${BASE_CFLAGS}"
BASE_CPPFLAGS=""

# prefix configuration
CONF_PREFIX="--prefix=${PREFIX}"
CONF_PREFIX_PREREQS="--prefix=${PREFIX_PREREQS}"

CMAKE_PREFIX="-D CMAKE_INSTALL_PREFIX=${PREFIX}"

# generic configure options
CONF_LANG="c,c++"
CONF_DISLIB="--disable-libada --disable-libssp --disable-libmudflap --disable-libgomp --disable-libffi --disable-libquadmath"
CONF_GNU="--with-gnu-as --with-gnu-ld"
CONF_RELEASE="--enable-checking=release --with-pkgversion='CROSS-GCC'"
CONF_GENOPTS="--enable-lto"
CONF_GENOPTSGCC_PREREQ="--with-gmp=${PREFIX_PREREQS} --with-mpfr=${PREFIX_PREREQS} --with-mpc=${PREFIX_PREREQS} --with-isl=${PREFIX_PREREQS} --with-libelf=${PREFIX_PREREQS}"
CONF_GENOPTSGCC="${CONF_GENOPTSGCC_PREREQ} --libexecdir=${PREFIX}/lib --with-system-zlib --with-zstd --enable-fixed-point --enable-static --disable-libstdcxx-pch --disable-libatomic --disable-threads --disable-tls --disable-decimal-float --disable-shared"
CONF_GENDISABLE="--disable-nls --disable-dependency-tracking"

# generic cmake configuration options
CMAKE_BASE="-D CMAKE_VERBOSE_MAKEFILE=TRUE ${CMAKE_PREFIX} -D CMAKE_BUILD_TYPE=Release"

STEPS_GEN="download unpack patch bootstrap mkbuilddir"

REQUIRED_CMDS+=" makeinfo yacc flex m4 make cmake gcc pkg-config wget"

# RUN
# user check
if [ "$(whoami)" == "root" ]; then
    echo "ERROR: This script cannot be run as root user!"
    exit 255
fi

# system tools check
for cmd in ${REQUIRED_CMDS}; do
    if [[ -z $(which ${cmd}) ]]; then
    echo "ERROR: Mandatory command '${cmd}' not found!"
    exit 255
    fi
done

source ${ROOTDIR}/VERSIONS
source ${ROOTDIR}/prereqs.sh
export PATH

# default variable values
STEPS+="binutils gcc "
ALL_DNADR+="${BINUTILS_DNADR} ${GCC_DNADR} "
