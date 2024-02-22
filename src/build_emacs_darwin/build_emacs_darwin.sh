#!/usr/bin/env bash
# This script is used to build Emacs from source on macOS.

# Pre-requisites:
# 1. Install Xcode from the App Store
# 2. Install Xcode command line tools
# 3. Install Homebrew (or MacPorts or Nix, but you're on your own there)
# 4. Install dependencies:
#      brew install \
#        autoconf \
#        automake \
#        libtool \
#        texinfo \
#        pkg-config \
#        gnutls \
#        gcc@13 \
#        imagemagick \
#        mailutils \
#        libgccjit \
#        jansson \
#        gnutls \
#        tree-sitter

GIT_REF="emacs-29"
PREFIX="/usr/local"
CFLAGS="-O3 -march=native -I/opt/local/include/gcc13"
LDFLAGS="-L/opt/local/lib/gcc13 \
	-Wl,-rpath,/opt/local/lib/gcc13"

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d "$THIS_DIR/emacs" ]; then
    git clone git://git.savannah.gnu.org/emacs.git
fi

cd "$THIS_DIR/emacs"

git checkout "${GIT_REF}" && git pull

./autogen.sh

./configure \
    --prefix="${PREFIX}" \
    --with-ns \
    --with-json \
    --with-tree-sitter \
    --with-native-compilation \
    --with-imagemagick \
    --with-mailutils \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}"

gmake -j $(sysctl -n hw.ncpu)

if [ -ne $? 0 ]; then
  exit 1
fi

gmake install

if [ -ne $? 0 ]; then
  exit 1
fi

cp -r nextstep/Emacs.app /Applications/

# Build without a native Cocoa application

gmake clean

./configure \
    --prefix="${PREFIX}" \
    --disable-ns-self-contained \
    --with-json \
    --with-tree-sitter \
    --with-native-compilation \
    --with-imagemagick \
    --with-mailutils \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}"

gmake -j $(sysctl -n hw.ncpu) && sudo gmake install
