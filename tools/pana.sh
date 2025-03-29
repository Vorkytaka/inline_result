#!/bin/bash

# This script runs the pana tool on a package
# Usage: ./tools/pana.sh

package_path="."

# Create a temporary folder and copy the package files
mkdir .tmp
cp -r "$package_path"/* ".tmp/"

fvm dart pub global activate pana ^0.21.0 # We use 0.21.0 because of dart 3.3.0
fvm dart pub global run pana ".tmp/"

rm -rf .tmp