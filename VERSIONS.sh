# toolchain main component versions
BINUTILS_VER="2.45"

#GCC_VER="14.3.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@7f5b5309ebc5fa66e003950341648d05f6e7062b@releases/gcc-14" #2025-07-27 14.3.x
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"

# prerequisite versions
ZLIB_NG_VER="2.2.4"
ZSTD_VER="1.5.7"
GMP_VER="6.3.0"
MPFR_VER="4.2.2"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.7.1"
ELFUTILS_VER="0.193"
