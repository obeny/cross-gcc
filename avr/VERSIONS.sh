# package versions

#LIBC_VER="2.2.1"
LIBC_VER="git@https://github.com/avrdudes/avr-libc.git@3279628c69a1de8e022a2c05bf3dab12c969c28f@main" #2.3.x-pre, 2025-09-24
LIBC_DNADR="${LIBC_VER}"

AVRDUDE_VER="8.1"

# download addresses
LIBC_DNADR="${LIBC_DNADR:=https://github.com/avrdudes/avr-libc/releases/download/avr-libc-${LIBC_VER//./_}-release/avr-libc-${LIBC_VER}.tar.bz2}"

AVRDUDE_DNADR="https://github.com/avrdudes/avrdude/archive/refs/tags/v${AVRDUDE_VER}.tar.gz;avrdude-${AVRDUDE_VER}"
