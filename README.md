# CW3 Unit Editor (prototype)

Theos / Objective-C++ overlay prototype for the Cartoon Wars 3 iOS app.

## Current milestone

- Target bundle ID: `com.gamevil.cartoonwars3.ios.apple.global.normal`
- Build architecture: ARM64
- Floating CW3 button and prototype panel
- Inventory scanner: not implemented
- Runtime unit-stat integration: not implemented
- Apply and Reset controls: intentionally disabled until the app's data model is verified

This milestone tests the Theos build pipeline and overlay lifecycle. It does not change game state or claim to edit unit performance.

## Build

Push to `main`, or use **Actions → Build CW3 Unit Editor → Run workflow**.

The workflow installs Theos on a macOS runner, compiles the ARM64 dylib, verifies the architecture, and uploads `CW3UnitEditor-arm64.dylib` as an Actions artifact.

## Files

- `Makefile` — Theos target and build settings
- `CW3UnitEditor.plist` — target bundle filter
- `Tweak.xm` — overlay prototype
- `.github/workflows/build.yml` — CI build

## Limitations

The artifact is unsigned. Building does not inject it into an IPA or sign a modified app. This prototype has no verified inventory adapter or verified runtime hooks. All stat controls remain locked.
