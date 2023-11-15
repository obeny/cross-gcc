#!/bin/sh

# toolchain main component versions
BINUTILS_VER="2.41"
#GCC_VER="13.2.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@28d9e033a8e95c024e27cb495db610aac37a0f88@releases/gcc-13"

# toolchain package urls
BINUTILS_DNADR="http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.bz2"
#GCC_DNADR="http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz"
GCC_DNADR="$GCC_VER"

# prerequisities versions
ZLIB_VER="1.3"
GMP_VER="6.3.0"
MPFR_VER="4.2.1"
MPC_VER="1.3.1"
ISL_VER="0.26"
EXPAT_VER="2.5.0"
ELFUTILS_VER="0.190"

# prerequisities package urls
ZLIB_DNADR="http://zlib.net/zlib-${ZLIB_VER}.tar.xz"
GMP_DNADR="https://gmplib.org/download/gmp/gmp-${GMP_VER}.tar.xz"
MPFR_DNADR="https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VER}.tar.xz"
MPC_DNADR="https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"
ISL_DNADR="https://libisl.sourceforge.io/isl-${ISL_VER}.tar.xz"
EXPAT_DNADR="https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VER//./_}/expat-${EXPAT_VER}.tar.xz"
ELFUTILS_DNADR="https://sourceware.org/elfutils/ftp/${ELFUTILS_VER}/elfutils-${ELFUTILS_VER}.tar.bz2"
