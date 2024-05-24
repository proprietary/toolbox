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
#        tree-sitter

GIT_REF="master"
PREFIX="/usr/local"
PKG_ROOT=$(brew --prefix)
CFLAGS="-O3 -march=native -I${PKG_ROOT}/include"
LDFLAGS="-L${PKG_ROOT}/lib/gcc/current -L${PKG_ROOT}/lib -Wl,-rpath,${PKG_ROOT}/lib/gcc/current"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

cc libgccjit_smoketest.c $CFLAGS $LDFLAGS -lgccjit -o libgccjit_smoketest
./libgccjit_smoketest
if [[ $? -ne 0 ]]; then
    cat <<EOF
Failed to compile and run an example program using libgccjit.
Please make sure you installed libgccjit with Homebrew and this script has the right paths"
EOF
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [--with-ns|--without-ns]"
    exit 1
fi

function parse_arguments() {
    WITH_NS=0
    while [[ $# -gt 0 ]]; do
        key="$1"
        case "$key" in
            --with-ns)
                WITH_NS=1
                shift
                ;;
            --without-ns)
                WITH_NS=0
                shift
                ;;
            *)
                echo "Unknown argument: $key"
                exit 1
                ;;
        esac
    done
}

parse_arguments "$@"
if [[ ${WITH_NS} -eq 1 ]]; then
    echo "Building as a NS app"
else
    echo "Building as a non-NS app"
fi

if [ ! -d "$THIS_DIR/emacs" ]; then
    git clone git://git.savannah.gnu.org/emacs.git
fi

cd "$THIS_DIR/emacs"

git clean -fxd && \
  git reset --hard && \
  git checkout "${GIT_REF}" && \
  git pull

./autogen.sh

if [[ "${WITH_NS}" -eq 1 ]]; then
    ./configure \
        --with-ns \
        --with-json \
        --with-tree-sitter \
        --with-native-compilation \
        --with-imagemagick \
        --with-mailutils \
        --with-xpm=ifavailable \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}"

    gmake -j $(sysctl -n hw.ncpu) && \
    gmake install && \
    cp -r nextstep/Emacs.app /Applications/
else
    # Build non-NS version for the terminal
    ./configure \
        --prefix="${PREFIX}" \
        --without-ns \
        --with-x-toolkit=no \
        --with-json \
        --with-tree-sitter \
        --with-native-compilation \
        --with-mailutils \
        --with-xpm=ifavailable \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}"

    gmake -j $(sysctl -n hw.ncpu) && \
        sudo gmake install
fi
