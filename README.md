# Flutter ESC/POS Network Universal

A high-performance, cross-platform (IO & Web) Flutter library for printing to ESC/POS thermal network printers (WiFi/Ethernet).

This package is a **forked and extended version** of [flutter_esc_pos_network](https://pub.dev/packages/flutter_esc_pos_network), rewritten for "universal" cross-platform support (IO & Web).

## ✨ Key Features

- 📱 **Cross-Platform**: Unified API for Android, iOS, Windows, macOS, Linux, and Web.
- 🖼️ **Widget Printing**: Render any Flutter Widget directly to your thermal printer with `printWidget`.
- 🚀 **Asynchronous Performance**: Uses `compute` (Isolates) for image processing on mobile/desktop to keep the UI thread smooth.
- 🔕 **Seamless Web Printing**: Sends the full receipt bitmap as a single ESC/POS command — no chunking, no white-line seam artifacts.
- 🌐 **Web Bridge**: Native TCP support on Web via the [Local TCP Extension](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf).
- 🔄 **Real-time Status**: Broadcast stream for monitoring the availability of the web printing bridge.
- 📏 **Custom Paper Sizes**: Robust support for 58mm, 72mm, and 80mm paper widths.

## 🔗 Official Resources

- **GitHub Repository**: [Source Code](https://github.com/algonize/local_tcp)
- **GitHub Download Link**: [Download Source & Scripts](https://github.com/algonize/local_tcp/archive/refs/heads/main.zip)
- **Chrome Web Store**: [Local TCP Extension](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf)
- **Video Tutorial**: [Setup Guide & Demo](https://www.youtube.com/watch?v=D0Zdp7xysy8)

## 🚀 Getting Started

> [!TIP]
> **For proper installation and implementation details, please check the [example](example) folder very well.**

### 1. Unified Interface Usage

```dart
import 'package:flutter_esc_pos_network_universal/flutter_esc_pos_network_universal.dart';

final printer = PrinterNetworkManager(
  '192.168.1.100',
  paperSize: ThermalPosPrinterPageSize.size80mm,
);

PosPrintResult connect = await printer.connect();
if (connect == PosPrintResult.success) {
  // Print standard ESC/POS bytes
  await printer.printTicket(ticketBytes);
  
  printer.disconnect();
}
```

### 2. Printing a Flutter Widget

```dart
await printer.printWidget(
  context,
  child: MyReceiptWidget(), // Any standard Flutter widget
);
```

## 🌐 Web Architecture (The Bridge)

Since standard web browsers cannot directly open TCP sockets, this package uses a **Native Messaging Bridge**:

1. **Extension**: The [Local TCP Chrome Extension](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf) acts as the bridge.
2. **Native Host**: A small setup script (available on [GitHub](https://github.com/algonize/local_tcp/archive/refs/heads/main.zip)) runs on the user's computer to handle the actual TCP sockets.
3. **Seamless API**: The package automatically detects the platform and routes commands through the extension if running on Web, providing a single, unified development experience.

## 🤝 Support & PRs

We welcome community contributions! Please report bugs, suggest features, or submit PRs to help improve the universal printing experience.

---
Built with ❤️ by Algoramming Systems Ltd.