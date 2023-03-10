#!/bin/bash

# die if any error occured or variable is unset
set -e
set -u

#
# GENERIC STAGE FUNCTIONS
#

function stage_download()
{
    download_all
}

function stage_unpack()
{
    extract_all
}

#
# HELPER FUNCTIONS
#

# -----------------------------------------
function abspath()
{
    echo "$(readlink -f "$1")"
}

# -----------------------------------------
function die()
{
    echo "!!! ${1}"
    exit 1
}

# -----------------------------------------
function do_patch()
{
    if [ ${2} -z ]
    then
	patch -p0 < ${1} || die "patching: ${1} failed"
    else
	patch -p${2} < ${1} || die "patching: ${1} failed"
    fi
}

# -----------------------------------------
function remove_bdir()
{
    cd ${BUILDDIR}
    rm -rf ${1}
}


# -----------------------------------------
function run_make()
{
    make ${MAKEOPTS} $@
}

# -----------------------------------------
function urlproto()
{
    DPATH="${1}"

    if [ ! -z "`echo ${DPATH} | grep '@'`" ]; then
	echo "`echo ${DPATH} | cut -f 1 -d '@'` `echo ${DPATH} | cut -f 2- -d '@'`"
    else
	echo "web ${DPATH}"
    fi
}

# -----------------------------------------
function srcdir()
{
    local DNLPATH=${1}
    local URLPROTO=$(urlproto ${DNLPATH})
    local PROTO="`echo ${URLPROTO} | cut -f 1 -d ' '`"
    local URL="`echo ${URLPROTO} | cut -f 2 -d ' '`"

    local REV="`echo ${URL} | cut -f 2 -d '@'`"
    local DIR="`echo ${URL} | cut -f 3 -d '@'`-${REV}"

    case "${PROTO}" in
	svn|git)
	    echo "${DIR}"
	    ;;
	*)
	    local FILE="`basename ${DNLPATH}`"
	    echo $FILE | sed -e 's/\.tar\..*//g'
	    ;;
    esac
}

# -----------------------------------------
function download()
{
    local DNLPATH=${1}
    local URLPROTO=$(urlproto ${DNLPATH})
    local PROTO="`echo ${URLPROTO} | cut -f 1 -d ' '`"
    local URL="`echo ${URLPROTO} | cut -f 2 -d ' '`"

    case "${PROTO}" in
	svn)
	    download_svn ${URL}
	    ;;
	git)
	    download_git ${URL}
	    ;;
	*)
	    download_web ${URL}
	    ;;
    esac
}

# -----------------------------------------
function download_web()
{
    local FILE="`basename ${1}`"

    if [ ! -e "${FILE}" ]
    then
	print_uinfo "downloading: ${FILE}"
	wget --no-check-certificate "${1}" || die "download failed: ${FILE}"
    else
	print_info "file already exists: ${FILE}"
    fi
}

# -----------------------------------------
function download_svn()
{
    local URL=${1}

    local SVN_URL="`echo ${URL} | cut -f 1 -d '@'`"
    local SVN_REV="`echo ${URL} | cut -f 2 -d '@'`"
    local SVN_DIR="`echo ${URL} | cut -f 3 -d '@'`-${SVN_REV}"

    if [ ! -d "${SVN_DIR}" ]
    then
	print_info "SVN CHECKOUT: svn co -r ${SVN_REV} ${SVN_URL} ${SVN_DIR}"
	svn co -r ${SVN_REV} ${SVN_URL} ${SVN_DIR} || die "SVN checkout failed ${SVN_DIR}"
    else
	print_info "SVN dir already exists: ${SVN_DIR}"
    fi
}

# -----------------------------------------
function download_git()
{
    local URL=${1}

    local GIT_URL="`echo ${URL} | cut -f 1 -d '@'`"
    local GIT_HASH="`echo ${URL} | cut -f 2 -d '@'`"
    local GIT_DIR="`echo ${URL} | cut -f 3 -d '@'`-${GIT_HASH}"

    if [ ! -d "${GIT_DIR}" ]
    then
	print_info "GIT CLONE: git clone ${GIT_URL} ${GIT_DIR}; hash: ${GIT_HASH}"
	git clone ${GIT_URL} ${GIT_DIR}
	cd ${GIT_DIR}
	git checkout ${GIT_HASH}
	cd ..
    else
	print_info "GIT dir already exists: ${GIT_DIR}"
    fi
}

# -----------------------------------------
function download_all()
{
    for DWN in ${ALL_DNADR}
    do
	download ${DWN}
    done
}

# -----------------------------------------
function exec_stage()
{
    if [ ! -e stage_${1} ]
    then
	print_stepinfo "running stage: ${1}"
	stage_${1} || die "couldn't execute: stage_${1}"
	print_info "stage: ${1} completed successfully"

	cd ${BUILDDIR}
	touch stage_${1}
	env > stage_${1}.env
    else
	print_info " stage: ${1} already completed: skipping it..."
    fi
}

# -----------------------------------------
function extract()
{
    local DNLPATH=${1}
    local URLPROTO=$(urlproto ${DNLPATH})
    local PROTO="`echo ${URLPROTO} | cut -f 1 -d ' '`"
    local REPO="`echo ${URLPROTO} | cut -f 2 -d ' '`"
    local REPO_DIR="`srcdir ${DNLPATH}`"

    case "${PROTO}" in
	svn|git)
	    print_info "No need to unpack repo ${REPO}"
	    ;;
	*)
	    local FILE="`basename ${1}`"
	    local DIR="${FILE}"
	    DIR=${DIR%%.tar.*}
	    if [ ! -e "${DIR}" ]; then
		print_uinfo "extracting: ${FILE}"
		tar xf "${FILE}" || die "extraction failed: ${FILE}"
	    else
		print_info "source already exists: ${DIR}"
	    fi
	    ;;
    esac

    case "${PROTO}" in
	svn|git)
	    print_info "Checking for bootstrap script"
	    cd ${REPO_DIR}
	    BOOTSTRAP="`find . -name '*bootstrap*'`"
	    if [ ! -z "${BOOTSTRAP}" ]; then
		print_info "Running bootstrap ${BOOTSTRAP}"
		./${BOOTSTRAP}
	    else
		print_info "No bootstrap found, skipping"
	    fi
	    cd ..
	    ;;
	*)
	    ;;
    esac
}

# -----------------------------------------
function extract_all()
{
    for EXT in ${ALL_DNADR}
    do
	extract ${EXT}
    done
}

# -----------------------------------------
function get_processor_count()
{
    echo "`cat /proc/cpuinfo | grep processor | wc -l`"
}

# -----------------------------------------
function print_info()
{
    echo "iii ${1}"
}

# -----------------------------------------
function print_details()
{
    echo "----- Running: ${1} -----"
    echo "  ${2}"
}

# -----------------------------------------
function print_stepinfo()
{
    echo "*** ${1}"
}

# -----------------------------------------
function print_uinfo()
{
    echo ">>> ${1}"
}

# -----------------------------------------
function run()
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
    read
    for STEP in ${ALL_STEPS}
    do
	exec_stage ${STEP}
    done

    # do the cleanup
    rm -rf ${PREFIX}/share/{info,locale,man}
    rm -rf ${PREFIX}/prereqs

    echo ">>> ALL FINISHED <<<"
    read
}

# -----------------------------------------
function show_info()
{
    prereq_info
    echo
    target_info
    echo
    echo "press RETURN key to continue..."
    read
}

# -----------------------------------------
function set_buildflags_base()
{
    export CFLAGS="${BASE_CFLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${BASE_LDFLAGS}"
    export CPPFLAGS="${BASE_CPPFLAGS}"
}

# -----------------------------------------
function clear_buildflags()
{
    unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

# -----------------------------------------
function configure_binutils()
{
    ARGS="${CONF_COMMON} ${CONF_GENOPTS} ${CONF_GNU} ${CONF_RELEASE} ${CONF_DISLIB} ${CONF_GENDISABLE} --with-sysroot=${PREFIX}/${TARGET} --with-system-zlib --enable-plugins $@"
    print_details "binutils" "configure ${ARGS}"

    SDIR="`srcdir ${BINUTILS_DNADR}`"
    ../${SDIR}/configure ${ARGS}
}

# -----------------------------------------
function configure_gcc()
{
    ARGS="${CONF_COMMON} ${CONF_GENOPTS} ${CONF_GENOPTSGCC} ${CONF_GNU} ${CONF_RELEASE} ${CONF_DISLIB} ${CONF_GENDISABLE} --enable-languages="${CONF_LANG}" $@"
    print_details "gcc" "configure ${ARGS}"

    SDIR="`srcdir ${GCC_DNADR}`"
    ../${SDIR}/configure ${ARGS}
}

# -----------------------------------------
function configure_gen()
{
    DIR=${1}
    shift

    ARGS="${CONF_PRFX} $@"
    print_details "${DIR}" "configure ${ARGS}"

    ../${DIR}/configure ${ARGS}
}

# -----------------------------------------
function stage_binutils-generic()
{
    cd ${BUILDDIR}/build-binutils
    set_buildflags_base

    configure_binutils || die "binutils configuration failed..."
    run_make || die "binutils make failed..."
    make -j1 install || die "binutils installation failed..."

    remove_bdir build-binutils || die "removing builddir failed..."
}

# generic environment configuration
CURDIR=`pwd`
source ${CURDIR}/../VERSIONS.sh
HOST="x86_64-pc-linux-gnu"
TARGET=`basename ${CURDIR}`
PREFIX=`abspath ${CURDIR}/../tc_${TARGET}`
PREFIX_PREREQS="${PREFIX}/prereqs"
PATH="${PREFIX}/bin:${PATH}"
BUILDDIR=${BUILDDIR:-/tmp/tc_${TARGET}-build}
JOBS=$(get_processor_count)
MAKEOPTS="-j${JOBS}"

BASE_CFLAGS="-O2 -pipe -g0 -w -ffunction-sections -fdata-sections -s -Wno-error -w"
BASE_LDFLAGS="-O1"
BASE_CXXFLAGS="${BASE_CFLAGS}"
BASE_CPPFLAGS="${BASE_CXXFLAGS}"

# generic configure options
CONF_LANG="c,c++"
CONF_PRFX="--prefix=${PREFIX}"
CONF_DISLIB="--disable-libada --disable-libssp --disable-libmudflap --disable-libgomp --disable-libffi --disable-libquadmath"
CONF_GNU="--with-gnu-as --with-gnu-ld"
CONF_RELEASE="--enable-checking=release --with-pkgversion='CROSS-GCC'"
CONF_GENOPTS="--enable-lto"
CONF_GENOPTSGCC_PREREQ="--with-gmp=${PREFIX_PREREQS} --with-mpfr=${PREFIX_PREREQS} --with-mpc=${PREFIX_PREREQS} --with-isl=${PREFIX_PREREQS} --with-libelf=${PREFIX_PREREQS}"
CONF_GENOPTSGCC="${CONF_GENOPTSGCC_PREREQ} --libexecdir=${PREFIX}/lib --with-system-zlib --enable-fixed-point --enable-static --disable-threads --disable-tls --disable-decimal-float --disable-shared"
CONF_GENDISABLE="--disable-nls --disable-dependency-tracking"

STEPS_GEN="download unpack mkbuilddir"

# RUN
if [ `whoami` == "root" ]
then
    echo "ERROR: This script cannot be run as root user!"
    exit
fi

source ${CURDIR}/../prereqs.sh
export PATH

# default variable values
STEPS+="binutils gcc "
ALL_DNADR+="$BINUTILS_DNADR $GCC_DNADR "
