# package versions

GDB_VER="16.1"

#NEWLIB_VER="4.5.0.20241231"
NEWLIB_VER="git@git://sourceware.org/git/newlib-cygwin.git@5ee0e96939e8784d4cbd2b2896b0ffbf88a00d86@main" #4.5.0+, 2025-01-16
NEWLIB_DNADR="${NEWLIB_VER}"

#OPENOCD_VER="0.12.0"
OPENOCD_VER="git@https://github.com/obeny/openocd.git@7541edfcdd6f2ff6b65e313bf17f811f38f3eb2d@master-custom" #0.12+, 2024-11-13
OPENOCD_DNADR="${OPENOCD_VER}"

# download addresses
GDB_DNADR="http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VER}.tar.xz"

NEWLIB_DNADR="${NEWLIB_DNADR:=ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz}"
OPENOCD_DNADR="${OPENOCD_DNADR:=http://sourceforge.net/projects/openocd/files/openocd/${OPENOCD_VER}/openocd-${OPENOCD_VER}.tar.bz2}"
