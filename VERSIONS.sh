# toolchain main component versions
BINUTILS_VER="2.45"

#GCC_VER="15.2.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@2360c6156721759cab9484b8ee761aa4ae4d2574@releases/gcc-15" #2025-09-23 15.2.x
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=https://ftpmirror.gnu.org/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"

# prerequisite versions
ZLIB_NG_VER="2.2.5"
ZSTD_VER="1.5.7"
GMP_VER="6.3.0"
MPFR_VER="4.2.2"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.7.1"
ELFUTILS_VER="0.193"
