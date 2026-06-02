#!/usr/bin/env bash

SCRIPTDIR=$(realpath $(dirname "${BASH_SOURCE[0]}"))

function retry_command {
  # Package servers tend to be unreliable at times..
  # Retry a bunch of times.
  local RETRIES=10

  for i in $(seq 1 "$RETRIES"); do
    "$@" && break
    if [ "$i" == "$RETRIES" ]; then
      echo "Command \"$@\" failed after ${RETRIES} retries."
      exit 1
    fi
  done
}

# It's probably a good idea to check https://apt.llvm.org before editing LLVM_VER file
LLVM_VER=$(cat "$SCRIPTDIR/LLVM_VER")

# Workaround for https://github.com/actions/runner-images/issues/675
retry_command wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
retry_command sudo apt-add-repository -n "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${LLVM_VER} main"

# Workaround for ancient cmake version
retry_command wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

retry_command sudo apt-get update
retry_command sudo apt-get -y install \
  build-essential clang-${LLVM_VER} cmake curl extra-cmake-modules git libasound2-dev libcurl4-openssl-dev libdbus-1-dev libdecor-0-dev libegl-dev libevdev-dev \
  libfontconfig-dev libfreetype-dev libfuse2 libgtk-3-dev libgudev-1.0-dev libharfbuzz-dev libinput-dev libopengl-dev libpipewire-0.3-dev libpulse-dev \
  libssl-dev libudev-dev libva-dev libwayland-dev libx11-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev \
  libxcb-glx0-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev \
  libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-xinput-dev libxcb-xkb-dev libxext-dev libxkbcommon-x11-dev \
  libxrandr-dev libxss-dev lld-${LLVM_VER} llvm-${LLVM_VER} nasm ninja-build patchelf pkg-config zlib1g-dev libc++-${LLVM_VER}-dev
