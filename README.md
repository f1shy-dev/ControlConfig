# ControlConfig

<p align="center">
  <img src="ControlConfig/Assets.xcassets/AppIcon.appiconset/Icon Template 512pt.png" alt="ControlConfig Icon" width="128" height="128">
</p>

<p align="center">
  <strong>Customize your iOS Control Center like never before</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0--16.5-blue" alt="iOS 15.0-16.5">
  <img src="https://img.shields.io/badge/Swift-5-orange" alt="Swift 5">
  <img src="https://img.shields.io/github/license/f1shy-dev/ControlConfig" alt="License">
</p>

---

## About

ControlConfig is a powerful iOS customization tool that lets you modify Control Center modules without requiring a jailbreak. Change icons, colors, functionality, and more — all with an intuitive SwiftUI interface.

## Features

- **Custom Module Icons** — Replace default icons with your own images or choose from built-in alternatives
- **Color Customization** — Change the colors of Control Center tiles to match your aesthetic
- **Module Actions** — Modify what happens when you tap or long-press a tile
- **Reorder Modules** — Arrange your Control Center exactly how you want it
- **Backup & Restore** — Save your customizations and restore them anytime
- **Icon Packs** — Support for custom icon packs

## Compatibility

| iOS Version | Support | Method |
|-------------|---------|--------|
| iOS 15.0 – 16.1.2 | ✅ Full | MDC (MacDirtyCow) |
| iOS 16.2 Dev Beta 1/2 | ✅ Full | MDC |
| iOS 16.3 – 16.5 | ✅ Full | KFD |
| iOS 16.6 Beta 1 | ✅ Full | KFD |
| iOS 16.5.1+ | ❌ Not Supported | — |

> **Note:** TrollStore installation is also supported for enhanced permissions.

## Installation

### Via TrollStore (Recommended)
1. Download the latest `.tipa` or `.ipa` from [Releases](https://github.com/f1shy-dev/ControlConfig/releases/latest)
2. Open the file with TrollStore
3. Launch ControlConfig and enjoy!

### Via Sideloading
1. Download the latest `.ipa` from [Releases](https://github.com/f1shy-dev/ControlConfig/releases/latest)
2. Sideload using your preferred method (AltStore, Sideloadly, etc.)
3. Trust the developer certificate in Settings
4. Launch ControlConfig

## Usage

1. **First Launch** — The app will request necessary permissions and create a backup of your current Control Center configuration
2. **Select a Module** — Tap on any Control Center module to customize it
3. **Make Changes** — Modify icons, colors, or actions as desired
4. **Apply** — Save your changes and respring to see them take effect

## URL Schemes

ControlConfig supports URL schemes for automation:

```
controlconfig://respring
controlconfig://respring?type=backboard
controlconfig://respring?type=frontboard
controlconfig://respring?type=legacy
```

## Building from Source

1. Clone the repository
   ```bash
   git clone https://github.com/f1shy-dev/ControlConfig.git
   ```
2. Open `ControlConfig.xcodeproj` in Xcode
3. Select your development team
4. Build and run on your device

## Credits

- **[f1shy-dev](https://github.com/f1shy-dev)** — Main developer
- **[Cowabunga](https://github.com/leminlimez/Cowabunga)** — Inspiration and code reference
- **[BomberFish](https://github.com/BomberFish)** — Contributions and support
- **[Ian Beer](https://twitter.com/i41nbeer)** — MacDirtyCow exploit
- **KFD Team** — KFD exploit

## Disclaimer

This software is provided for educational and personal use only. Use at your own risk. The developers are not responsible for any damage to your device. Always make backups before making system modifications.

## License

This project is open source. See the repository for license details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/f1shy-dev">f1shy-dev</a>
</p>
