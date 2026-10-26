#!/bin/bash

FLUTTER_VERSION="3.27.0"

if cd flutter; then
  git fetch --tags
  git checkout $FLUTTER_VERSION
  cd ..
else
  git clone https://github.com/flutter/flutter.git --branch $FLUTTER_VERSION --depth 1
fi

flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get