# toolchain main component versions
BINUTILS_VER="2.45"

#GCC_VER="14.3.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@0f8bacc8b2e62d3b81d64ae466ee994d3cab72a4@releases/gcc-14" #2025-08-10 14.3.x
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"

# prerequisite versions
ZLIB_NG_VER="2.2.5"
ZSTD_VER="1.5.7"
GMP_VER="6.3.0"
MPFR_VER="4.2.2"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.7.1"
ELFUTILS_VER="0.193"
