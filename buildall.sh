#!/usr/bin/env bash

# Build the app for android and linux.

set -e
#set -x

versionpattern='version: ([0-9\.]*)\+.*'
[[ $(cat pubspec.yaml | grep version) =~ $versionpattern ]]
version=${BASH_REMATCH[1]}

arch=$(uname -m)
projectName=magic_life_wheel
apkName=$projectName-$version.apk
aabName=$projectName-$version.aab
linuxArchiveName=$projectName-$version-linux-$arch.tar.gz
webArchiveName=$projectName-$version-web.tar.gz
baseDir=$(pwd)
outDir=$baseDir/out

flutter pub get

if [ $arch == "x86_64" ]; then
    rm -rf $outDir
    mkdir $outDir

    echo "Building apk"
    flutter build apk
    cp $baseDir/build/app/outputs/flutter-apk/app-release.apk $outDir/$apkName

    echo "Building appbundle"
    flutter build appbundle
    cp $baseDir/build/app/outputs/bundle/release/app-release.aab $outDir/$aabName

    echo "Building web"
    flutter build web
    tar -czf $outDir/$webArchiveName -C $baseDir/build/web .

    echo "Building linux x64"
    flutter build linux
    tar -czf $outDir/$linuxArchiveName -C $baseDir/build/linux/x64/release/bundle .

    echo "All builds completed $outDir"
elif [ $arch == "aarch64" ]; then
    rm -rf $outDir
    mkdir $outDir
    
    echo "Building linux arm64"
    flutter build linux
    tar -czf $outDir/$linuxArchiveName -C $baseDir/build/linux/arm64/release/bundle .

    echo "All builds completed $outDir"
else
    echo "Supported platform not detected!"
    echo "Current platform is $arch"
fi
