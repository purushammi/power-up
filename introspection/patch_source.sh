#!/bin/bash
# Copyright 2017 IBM Corp.
#
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Prepare and apply all patches for:
#
# 1) general fixes (e.g. backports) that aren't present in the release
#    we're building
#
# 2) updates specific to _building_ on POWER (but not fixes specific
#    to packaging; those belong in the packaging steps
#
# Exit 0 on success; 1 on failure
#
set -e

if [ -z "$1" -o ! -z "$2" ]; then
    echo "Usage: $(basename $0) <source-tree-base>"
    exit 1
fi

SOURCE="$1"
OPWD=$(pwd)

if [ ! -d "$1" ]; then
    echo "ERROR: $SOURCE is not a directory"
    exit 1
fi

if [ -x "./prepare_patches.sh" ]; then
    echo "Preparing patches"
    if ! ./prepare_patches.sh; then
        echo "ERROR: Failed to prepare patches"
        exit 1
    fi
fi

cd "${SOURCE}"
ls -1 ../patches/*patch 2>/dev/null \
    | sort | while read pfile
do
    echo "Applying patch: ${pfile}"
    if ! patch -p1 < "${pfile}"; then
        echo "ERROR: Patch application failed ${pfile}"
        exit 1
    fi
done

exit 0

