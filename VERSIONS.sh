# toolchain main component versions
BINUTILS_VER="2.43"

#GCC_VER="14.2.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@44da17c12bc4e0e6ded60e927bf38b46638a2594@releases/gcc-14" #2024-12-19
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"


# prerequisite versions
ZLIB_VER="1.3.1"
GMP_VER="6.3.0"
MPFR_VER="4.2.1"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.6.4"
ELFUTILS_VER="0.192"
