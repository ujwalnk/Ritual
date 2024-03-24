#!/bin/bash

# Navigate to your Flutter project directory
mkdir ./release

echo "Building APK"

# Build APK
flutter build apk --release

# Move APK to current directory
mv build/app/outputs/flutter-apk/app-release.apk ./release/app-release.apk

# Build AAB
flutter build appbundle --release

# Move AAB to current directory
mv build/app/outputs/bundle/release/app-release.aab ./release/app-release.aab

cd ./release

# Generate SHA256 hash for APK
sha256sum app-release.apk > app-release.apk.sha256

# Generate SHA256 hash for AAB
sha256sum app-release.aab > app-release.aab.sha256