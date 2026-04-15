# Flutter ESC/POS Network Universal

A high-performance, cross-platform (IO & Web) Flutter library for printing to ESC/POS thermal network printers (WiFi/Ethernet).

This package is a "universal" rewrite of `flutter_esc_pos_network`, designed to support all Flutter platforms seamlessly, including **Web Support via a specialized Chrome Extension Bridge**.

## ✨ Key Features

- 📱 **Cross-Platform**: Unified API for Android, iOS, Windows, macOS, Linux, and Web.
- 🖼️ **Widget Printing**: Render any Flutter Widget directly to your thermal printer with `printWidget`.
- 🚀 **Asynchronous Performance**: Uses `compute` (Isolates) for image processing to keep the UI thread smooth.
- 📏 **Chunked Printing**: Automatically splits long receipts into chunks to prevent buffer overflow and ensure smooth web printing.
- 🌐 **Web Bridge**: Native TCP support on Web via the [Local TCP Extension](https://chromewebstore.google.com/detail/local-tcp/bjmaihdjjkbjdjjbjbjbjbjbjbjbjbjb).
- 🔄 **Real-time Status**: Broadcast stream for monitoring the availability of the web printing bridge.
- 📏 **Custom Paper Sizes**: Robust support for 58mm, 72mm, and 80mm paper widths.

## 🔗 Official Resources

- **GitHub Repository**: [Download Source & Scripts](https://github.com/algonize/local_tcp/archive/refs/heads/main.zip)
- **Chrome Web Store**: [Local TCP Extension](https://chromewebstore.google.com/detail/local-tcp/bjmaihdjjkbjdjjbjbjbjbjbjbjbjbjb)
- **Video Tutorial**: [Setup Guide & Demo](https://www.youtube.com/watch?v=D0Zdp7xysy8)

## 🚀 Getting Started

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

1. **Extension**: The [Local TCP Chrome Extension](https://chromewebstore.google.com/detail/local-tcp/bjmaihdjjkbjdjjbjbjbjbjbjbjbjbjb) acts as the bridge.
2. **Native Host**: A small setup script (available on [GitHub](https://github.com/algonize/local_tcp/archive/refs/heads/main.zip)) runs on the user's computer to handle the actual TCP sockets.
3. **Seamless API**: The package automatically detects the platform and routes commands through the extension if running on Web, providing a single, unified development experience.

## 🛠️ Performance Configuration

You can tune the `chunkHeight` to balance printing speed vs. memory usage. The default is `100` pixels, which is optimized for smooth web printing.

```dart
final printer = PrinterNetworkManager(
  host,
  chunkHeight: 100, // Balanced for Web stability
);
```

## 🤝 Support & PRs

We welcome community contributions! Please report bugs, suggest features, or submit PRs to help improve the universal printing experience.

---
Built with ❤️ by Algoramming