#!/bin/bash

# This script runs the pana tool on a package
# Usage: ./tools/pana.sh

package_path="."

# Create a temporary folder and copy the package files
mkdir .tmp
mkdir ".tmp/"
cp -r "$package_path"/* ".tmp/"

dart pub global activate pana
dart pub global run pana ".tmp/"

rm -rf .tmp