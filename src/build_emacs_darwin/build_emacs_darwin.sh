#!/usr/bin/env bash
# This script is used to build Emacs from source on macOS.

# Pre-requisites:
# 1. Install Xcode from the App Store
# 2. Install Xcode command line tools
# 3. Install these Homebrew packages (or MacPorts or Nix, but you're on your own there)
#      brew install \
#        autoconf \
#        automake \
#        libtool \
#        texinfo \
#        pkg-config \
#        gnutls \
#        gcc \
#        imagemagick \
#        mailutils \
#        libgccjit \
#        jansson \
#        tree-sitter \
#        coreutils \
#        make

xcode-select --install
brew install \
  autoconf \
  automake \
  libtool \
  texinfo \
  pkg-config \
  gnutls \
  gcc \
  imagemagick \
  mailutils \
  libgccjit \
  jansson \
  tree-sitter \
  coreutils \
  make

GIT_REF="master"
PREFIX="/usr/local"
PKG_ROOT=$(brew --prefix)
CFLAGS="-O3 -march=native -I${PKG_ROOT}/include"
LDFLAGS="-L${PKG_ROOT}/lib/gcc/current -L${PKG_ROOT}/lib -Wl,-rpath,${PKG_ROOT}/lib/gcc/current"
THIS_DIR="$( cd "$(dirname "$0")"; pwd )"

cc libgccjit_smoketest.c $CFLAGS $LDFLAGS -lgccjit -o libgccjit_smoketest
./libgccjit_smoketest
if [[ $? -ne 0 ]]; then
    cat <<EOF
Failed to compile and run an example program using libgccjit.
Please make sure you installed libgccjit with Homebrew and this script has the right paths"
EOF
    exit 1
fi

if [ ! -d "$THIS_DIR/emacs" ]; then
    git clone git://git.savannah.gnu.org/emacs.git
fi

cd "$THIS_DIR/emacs"

function build() {
    local with_ns=$1
    local configure_flags="--with-tree-sitter --with-native-compilation --with-imagemagick --with-mailutils --with-x-toolkit=no --with-xpm=ifavailable --with-gnu-tls"

    git clean -fxd && \
    git reset --hard && \
    git checkout "${GIT_REF}" && \
    git pull

    ./autogen.sh

    if [[ "${with_ns}" == "with_ns" ]]; then
        configure_flags="--with-ns ${configure_flags}"
    else
        # Build non-NS version for the terminal
        configure_flags="--prefix="${PREFIX}" --without-ns ${configure_flags}"
    fi

    ./configure \
        ${configure_flags} \
        CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

    gmake -j $(sysctl -n hw.ncpu)

    if [[ "${with_ns}" == "with_ns" ]]; then
         gmake install
         cp -r nextstep/Emacs.app /Applications/
    else
         sudo gmake install
    fi
}

build with_ns
build without_ns
