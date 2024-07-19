#!/usr/bin/env bash

# Build the android apk.

set -e
#set -x

versionpattern='version: ([0-9\.]*)\+.*'
[[ $(cat pubspec.yaml | grep version) =~ $versionpattern ]]
version=${BASH_REMATCH[1]}

arch=$(uname -m)
projectName=magic_life_wheel
apkName=$projectName-$version.apk
baseDir=$(pwd)
outDir=$baseDir/out

flutter pub get

if [ $arch == "x86_64" ]; then
    rm -rf $outDir
    mkdir $outDir

    echo "Building apk"
    flutter build apk
    cp $baseDir/build/app/outputs/flutter-apk/app-release.apk $outDir/$apkName

    echo "All builds completed $outDir"
else
    echo "Supported platform not detected!"
    echo "Current platform is $arch"
fi
