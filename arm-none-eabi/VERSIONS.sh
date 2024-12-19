# package versions

GDB_VER="15.2"

#NEWLIB_VER="4.4.0.20231231"
NEWLIB_VER="git@git://sourceware.org/git/newlib-cygwin.git@efa5401ea998ee01d79c63449f51cd36df938f42@main" #4.4.0+, 2024-12-16
NEWLIB_DNADR="${NEWLIB_VER}"

#OPENOCD_VER="0.12.0"
OPENOCD_VER="git@https://github.com/obeny/openocd.git@ae71ddd58a16af1c5c7ab2ab3d3a990fe98d4cab@master-custom" #0.12+, 2024-10-23
OPENOCD_DNADR="${OPENOCD_VER}"

# download addresses
GDB_DNADR="http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VER}.tar.xz"

NEWLIB_DNADR="${NEWLIB_DNADR:=ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz}"
OPENOCD_DNADR="${OPENOCD_DNADR:=http://sourceforge.net/projects/openocd/files/openocd/${OPENOCD_VER}/openocd-${OPENOCD_VER}.tar.bz2}"
