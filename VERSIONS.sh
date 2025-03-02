# toolchain main component versions
BINUTILS_VER="2.44"

#GCC_VER="14.2.0"
GCC_VER="git@git://gcc.gnu.org/git/gcc.git@04b5c8b90cd95611d99684282cc321f06a0b49c2@releases/gcc-14" #2025-02-28
GCC_DNADR="${GCC_VER}"

# toolchain package urls
BINUTILS_DNADR="${BINUTILS_DNADR:=http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz}"
GCC_DNADR="${GCC_DNADR:=http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz}"


# prerequisite versions
ZLIB_NG_VER="2.2.4"
GMP_VER="6.3.0"
MPFR_VER="4.2.2"
MPC_VER="1.3.1"
ISL_VER="0.27"
EXPAT_VER="2.7.1"
ELFUTILS_VER="0.192"
