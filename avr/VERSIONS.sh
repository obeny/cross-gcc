# package versions

LIBC_VER="2.2.1"
#LIBC_VER="git@https://github.com/avrdudes/avr-libc.git@b5f1355c33c4ba15bcfd577a313ca45aac723644@avr-libc-2_2" #2.2.1, 2024-07-18
#LIBC_DNADR="${LIBC_VER}"

AVRDUDE_VER="8.1"

# download addresses
LIBC_DNADR="${LIBC_DNADR:=https://github.com/avrdudes/avr-libc/releases/download/avr-libc-${LIBC_VER//./_}-release/avr-libc-${LIBC_VER}.tar.bz2}"

AVRDUDE_DNADR="https://github.com/avrdudes/avrdude/archive/refs/tags/v${AVRDUDE_VER}.tar.gz;avrdude-${AVRDUDE_VER}"
