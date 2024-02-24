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

GIT_REF="master"
PREFIX="/usr/local"
CFLAGS="-O3 -march=native -I/opt/local/include/gcc13"
LDFLAGS="-L/opt/local/lib/gcc13 \
	-Wl,-rpath,/opt/local/lib/gcc13"

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [--with-ns|--without-ns]"
    exit 1
fi

function parse_arguments() {
    WITH_NS=false
    while [[ $# -gt 0 ]]; do
        key="$1"
        case "$key" in
            --with-ns)
                WITH_NS=true
                shift
                ;;
            --without-ns)
                WITH_NS=false
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
echo "Building as a NS app: $WITH_NS…"

if [ ! -d "$THIS_DIR/emacs" ]; then
    git clone git://git.savannah.gnu.org/emacs.git
fi

cd "$THIS_DIR/emacs"

git clean -fxd && \
  git reset --hard && \
  git checkout "${GIT_REF}" && \
  git pull

./autogen.sh

if [[ "${WITH_NS}" == "false" ]]; then
    ./configure \
        --with-ns \
        --with-json \
        --with-tree-sitter \
        --with-native-compilation=aot \
        --with-imagemagick \
        --with-mailutils \
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
        --with-json \
        --with-tree-sitter \
        --with-native-compilation=aot \
        --with-imagemagick \
        --with-mailutils \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}"

    gmake -j $(sysctl -n hw.ncpu) && \
        sudo gmake install
fi
