#!/bin/bash

set -e

echo "Building OverSIP Debian package..."
echo "=================================="

# Check if we're in the right directory
if [ ! -f "debian/control" ]; then
    echo "Error: debian/control not found. Run this script from the package root directory."
    exit 1
fi

# Clean any previous build artifacts
echo "Cleaning previous build artifacts..."
rm -rf ../oversip_* ../oversip-* 2>/dev/null || true

# Using dpkg-buildpackage to build the package.
# Options:
# -tc: clean source tree after build
# -us: do not sign the source package
# -uc: do not sign the .changes file
# -b: build binary package only (no source)
# -d: do not check build dependencies (needed on Fedora/RPM systems)
echo "Starting package build with dpkg-buildpackage..."
dpkg-buildpackage -tc -us -uc -b -d

echo ""
echo "Package built successfully!"
echo ""

# Clean up temporary files (optional, -tc already does this)
# The -tc flag should clean the source tree, but we'll also clean
# the debian/files and log file as before.
echo "Cleaning up temporary files..."
rm -f debian/files debian/oversip.debhelper.log 2>/dev/null || true

echo ""
echo "Build complete. Packages are in the parent directory:"
echo "------------------------------------------------------"
ls -la ../oversip_* 2>/dev/null || ls -la ../oversip-* 2>/dev/null || echo "No package files found in parent directory."

