#!/bin/bash
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

set -ex

VERSION="${1:-"$(date +%Y.%m.%d)"}"
cd "$(dirname "$0")"

if echo "$VERSION" | egrep -q '^\d{4}\.\d{2}\.\d{2}$'; then
  NIGHTLY=true
  HHVM_PACKAGE="hhvm-nightly=${VERSION}-*"
else
  NIGHTLY=false
  HHVM_PACKAGE="hhvm=${VERSION}-*"
  MAJ_MIN=$(echo "$VERSION" | cut -f1,2 -d.)
  (git checkout "${MAJ_MIN}-lts" || git checkout "$MAJ_MIN" || true) 2>/dev/null
fi

docker build \
  --build-arg "HHVM_PACKAGE=$HHVM_PACKAGE" \
  -t "hhvm/hhvm:$VERSION" \
  hhvm-latest/

docker build \
  --build-arg "HHVM_BASE_IMAGE=hhvm/hhvm:$VERSION" \
  -t "hhvm/hhvm-proxygen:$VERSION" \
  hhvm-latest-proxygen/

if $NIGHTLY; then
  docker tag "hhvm/hhvm:$VERSION" hhvm/hhvm:nightly
  docker tag "hhvm/hhvm-proxygen:$VERSION" hhvm/hhvm-proxygen:nightly
fi

docker push hhvm/hhvm
docker push hhvm/hhvm-proxygen
