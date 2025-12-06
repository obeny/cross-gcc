#
# toolchain main component versions
# =================================
BINUTILS_VER="2.45.1"

#GCC_VER="15.2.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@2481b8b42213da13d6f24b76a30a7917f1b06ae0@releases/gcc-15" #2025-11-24 15.2.x
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=https://ftpmirror.gnu.org/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"

#
# prerequisite versions
# =====================
ZLIB_NG_VER="2.2.5"
ZSTD_VER="1.5.7"
GMP_VER="6.3.0"
MPFR_VER="4.2.2"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.7.3"
ELFUTILS_VER="0.194"

# prerequisite package urls
ZLIB_NG_DNADR="https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIB_NG_VER}.tar.gz;zlib-ng-${ZLIB_NG_VER}"
ZSTD_DNADR="https://github.com/facebook/zstd/releases/download/v${ZSTD_VER}/zstd-${ZSTD_VER}.tar.gz"
GMP_DNADR="https://gmplib.org/download/gmp/gmp-${GMP_VER}.tar.xz"
MPFR_DNADR="https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VER}.tar.xz"
MPC_DNADR="https://ftpmirror.gnu.org/mpc/mpc-${MPC_VER}.tar.gz"
ISL_DNADR="https://libisl.sourceforge.io/isl-${ISL_VER}.tar.xz"
EXPAT_DNADR="https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VER//./_}/expat-${EXPAT_VER}.tar.xz"
ELFUTILS_DNADR="https://sourceware.org/elfutils/ftp/${ELFUTILS_VER}/elfutils-${ELFUTILS_VER}.tar.bz2"
