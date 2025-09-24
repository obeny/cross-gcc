# package versions

GDB_VER="16.3"

#NEWLIB_VER="4.5.0.20241231"
NEWLIB_VER="git@git://sourceware.org/git/newlib-cygwin.git@275c91f518b9182c94bc33c2788d661f9b6e0a54@cygwin-3_6-branch" #4.5.0+, cygwin-3.6.5+, 2025-09-19
NEWLIB_DNADR="${NEWLIB_VER}"

#OPENOCD_VER="0.12.0"
OPENOCD_VER="git@https://github.com/obeny/openocd.git@31f90d15b8bce5efe05d77d56d79edfd45628b15@master-custom" #0.12+, 2025-09-17
OPENOCD_DNADR="${OPENOCD_VER}"

# download addresses
GDB_DNADR="https://ftpmirror.gnu.org/gdb/gdb-${GDB_VER}.tar.xz"

NEWLIB_DNADR="${NEWLIB_DNADR:=ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz}"
OPENOCD_DNADR="${OPENOCD_DNADR:=http://sourceforge.net/projects/openocd/files/openocd/${OPENOCD_VER}/openocd-${OPENOCD_VER}.tar.bz2}"
