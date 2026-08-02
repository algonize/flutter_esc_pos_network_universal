# Flutter ESC/POS Network Universal

[![pub package](https://img.shields.io/pub/v/flutter_esc_pos_network_universal.svg)](https://pub.dev/packages/flutter_esc_pos_network_universal)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20windows%20%7C%20macos%20%7C%20linux%20%7C%20web-blue.svg)](https://pub.dev/packages/flutter_esc_pos_network_universal)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A high-performance, **truly cross-platform** Flutter library for printing to ESC/POS thermal network printers (Wi‑Fi / Ethernet) over TCP — including **Flutter Web**.

One API. Identical code on mobile, desktop, and the browser. On native platforms it opens a direct TCP socket; on the web it routes through the companion **[Local TCP browser extension](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf)**, which the framework detects and uses automatically.

> This package is a forked and substantially extended version of [`flutter_esc_pos_network`](https://pub.dev/packages/flutter_esc_pos_network), re-architected for universal (IO **and** Web) support.

---

## ✨ Features

- **Universal API** — one code path for Android, iOS, Windows, macOS, Linux, and Web.
- **Widget printing** — render any Flutter `Widget` to the printer with `printWidget` (logos, QR codes, rich layouts, mixed scripts).
- **Raw ESC/POS** — send pre-built command bytes with `printTicket`; the full `flutter_esc_pos_utils` API (`Generator`, `PaperSize`, `CapabilityProfile`, …) is re-exported for you.
- **Off-thread image processing** — on mobile/desktop, bitmap rasterization runs in a background isolate (`compute`) to keep the UI smooth.
- **Seamless raster output** — the receipt bitmap is emitted as a single continuous ESC/POS image, avoiding the white-line seam artifacts of chunked rendering.
- **Robust bitmap pipeline** — captured widgets are normalized to 8‑bit and clamped to the print‑head width, so output is consistent across every renderer and device.
- **Multiple paper widths** — 58 mm, 72 mm, and 80 mm.

---

## 📋 Platform support

| Platform | Transport | Extra setup required |
|---|---|---|
| Android · iOS · Windows · macOS · Linux | Direct TCP socket (`dart:io`) | None |
| **Web** | [Local TCP browser extension](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf) + one‑click native host | **Yes** — see [Web setup](#-web-setup) |

Browsers cannot open raw TCP sockets, and thermal printers speak raw ESC/POS — so the web target relies on the Local TCP bridge to reach the printer. Native platforms have no such restriction and need nothing extra.

---

## 🚀 Installation

```yaml
dependencies:
  flutter_esc_pos_network_universal: <latest-version>
```

```dart
import 'package:flutter_esc_pos_network_universal/flutter_esc_pos_network_universal.dart';
```

---

## ⚡ Quick start

### Print raw ESC/POS bytes

```dart
final printer = PrinterNetworkManager(
  '192.168.1.100',
  port: 9100,
  paperSize: ThermalPosPrinterPageSize.size80mm,
  // On web, allow extra time so the bridge can wake a sleeping Wi‑Fi printer.
  timeout: const Duration(seconds: 30),
);

final profile = await CapabilityProfile.load();
final generator = Generator(PaperSize.mm80, profile);

final bytes = <int>[
  ...generator.text('ALGORAMMING CAFE',
      styles: const PosStyles(align: PosAlign.center, bold: true)),
  ...generator.text('Espresso .......... \$3.00'),
  ...generator.feed(2),
  ...generator.cut(),
];

// Connects, prints, and disconnects in one call (isDisconnect defaults to true).
final result = await printer.printTicket(bytes);
if (result != PosPrintResult.success) {
  debugPrint('Print failed: ${result.msg}');
}
```

Need to send several tickets on one connection? Pass `isDisconnect: false` and call `printer.disconnect()` yourself when done:

```dart
await printer.connect();
await printer.printTicket(ticket1, isDisconnect: false);
await printer.printTicket(ticket2, isDisconnect: false);
await printer.disconnect();
```

### Print a Flutter widget

```dart
await printer.printWidget(
  context,
  child: const MyReceiptWidget(), // any standard Flutter widget
);
```

The widget is rasterized and sent as a single ESC/POS image — ideal for logos, QR codes, and layouts that text commands can't express.

---

## 🌐 Web setup

> ### 🎬 New here? **[▶️ Watch the 2‑minute setup video](https://youtu.be/oY2_5x2MoEk?si=hJQcWfsiVZ6btSXQ)**
> The fastest way to get the web bridge working — follow along step by step.

On the web, the end user installs the **Local TCP** extension once; it ships a tiny native messaging host that owns the actual TCP socket.

1. **Install the extension** from the [Chrome Web Store](https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf) (works on Chrome, Edge, Chromium, and Brave).
2. **Open the extension popup → “Download One‑Click Installer.”** It auto‑detects the OS and installs the native host:
   - 🍎 **macOS** — open the `.pkg` and follow the prompts.
   - 🪟 **Windows** — run the `.exe` (per‑user, no admin rights).
   - 🐧 **Linux** — run the `.run` installer.
3. **Restart the browser.** The popup shows **Bridge Linked** when ready.

No files are copied by hand and no terminal is needed. Source, installers, and the setup video live in the extension repo: **[github.com/algoramming/local_tcp](https://github.com/algoramming/local_tcp)**.

### Detect the bridge before printing (recommended)

Because the web target depends on the extension being installed and linked, check availability first and guide the user if it's missing. A complete, copy‑pasteable Riverpod implementation — distinguishing *not installed*, *bridge offline*, and *ready* — is in the example app:

➡️ [`example/lib/provider/local_tcp_extension_provider.dart`](example/lib/provider/local_tcp_extension_provider.dart)

---

## 🏗️ How it works

The public `PrinterNetworkManager` is a thin facade that selects a platform implementation at compile time via conditional import:

```
PrinterNetworkManager  (public API)
        │
        ├── IO   →  dart:io Socket.connect(host, 9100)            # mobile / desktop
        │            └─ bitmap rasterized in a background isolate
        │
        └── Web  →  window.postMessage  ⇄  Local TCP extension    # browser
                     └─ extension's native host opens the socket
```

On the web, requests are serialized as `{ source: 'localtcp_req', messageId, action, host, port, data }` and matched to `localtcp_res` replies by `messageId`. The browser, extension, and native host together relay raw ESC/POS bytes to the printer and stream the result back.

---

## 📚 API reference

### `PrinterNetworkManager`

| Member | Description |
|---|---|
| `PrinterNetworkManager(host, {port = 9100, timeout = 5s, paperSize = size80mm, profile})` | Create a manager for a printer. |
| `Future<PosPrintResult> connect({timeout})` | Connect to the printer. |
| `Future<PosPrintResult> disconnect({timeout})` | Disconnect. |
| `Future<PosPrintResult> printTicket(List<int> data, {isDisconnect = true})` | Send raw ESC/POS bytes; auto‑connects if needed. |
| `Future<PosPrintResult> printWidget(BuildContext context, {required Widget child, isDisconnect = true})` | Rasterize and print a widget. |
| `bool get isConnected` · `ThermalPosPrinterPageSize get paperSize` · `CapabilityProfile? get profile` | State getters. |

### Enums

- **`PosPrintResult`** — `success`, `timeout`, `connectionRefused`, `socketError`, `ticketEmpty`, `printInProgress`, `disconnectError`, … Each carries a human‑readable `.msg`.
- **`ThermalPosPrinterPageSize`** — `size58mm`, `size72mm`, `size80mm`.

### Paper sizes

| Size | Render width | Underlying profile |
|---|---|---|
| `size58mm` | 384 px | 58 mm |
| `size72mm` | 512 px | 80 mm |
| `size80mm` | 576 px | 80 mm |

---

## ⚠️ Notes & tips

- **Web image processing runs on the main thread** (isolates aren't used on web). For very large receipts, prefer building bytes with `Generator` and calling `printTicket` over `printWidget`.
- On web, set a generous `timeout` (e.g. 30 s) so the bridge can wake a deep‑sleeping Wi‑Fi printer.
- The standard network‑printer port is `9100`.

---

## 🤝 Contributing

Bug reports, feature requests, and PRs are welcome — please open an issue or pull request on the [GitHub repository](https://github.com/algonize/flutter_esc_pos_network_universal).

## ⚖️ License

MIT © Algoramming Systems Ltd. — see [LICENSE](LICENSE).
