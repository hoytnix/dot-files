#!/usr/bin/sh
pacman -Qqen > "$(dirname "$0")/../../pkglist/arch.txt"