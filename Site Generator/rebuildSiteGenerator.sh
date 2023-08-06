#! /bin/zsh

# exit if any command fails (set option "exit immediately")
set -e

# build release variant of SiteGenerator
swift build --configuration release --arch arm64

# copy SiteGenerator to parent directory for easy access during development
cp .build/arm64-apple-macosx/release/SiteGenerator ../

# signal success
echo "Did rebuild $(cd .. && pwd)/SiteGenerator"