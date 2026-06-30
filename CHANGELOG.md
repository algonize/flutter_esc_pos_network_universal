# 1.0.3

- **Fix: Garbled receipts on physical iOS devices** — On real iPhones/iPads, `printWidget` receipts printed as random characters instead of the rendered image, while the iOS Simulator, Android and Web worked correctly. Root cause (confirmed on-device): real iOS renders/captures the widget through Impeller and can produce a **16-bit-per-channel bitmap** (`Format.uint16`) for wide-gamut/HDR displays; the Simulator, Android and Web produce ordinary 8-bit (`Format.uint8`) bitmaps. `flutter_esc_pos_utils` packs pixels into the ESC/POS bit-image **assuming 8 bits per pixel**, so a 16-bit bitmap yields double-length, bit-misaligned raster strips. Each strip's declared height stops matching its data, the `ESC *` command **desynchronizes**, and the printer drops out of graphics mode and prints the raster bytes as text.
  - The decoded bitmap is now **normalized to 8 bits per channel** (`Format.uint8`) before ESC/POS generation, so the raster data matches what the encoder expects on every platform.
  - The same 8-bit normalization is applied on the Web path as defense-in-depth, so a future browser/renderer change cannot reintroduce the issue.
  - As an additional safeguard, the bitmap is clamped to the print-head width (576 / 512 / 384 px for 80 / 72 / 58 mm); it only downscales when wider, so correctly-sized output is unchanged.
- **Docs**: Rewrote the README for clarity and professionalism, and updated the Web setup to the new one-click native installer flow for the Local TCP extension.

# 1.0.2

- **Fix: Seamless Long Receipts (Universal)** — Resolved the "white gap" issue on both Web and IO (macOS/Mobile) by generating the entire receipt as a single continuous ESC/POS command instead of slicing it into chunks.
- **Improvement: Transmission Flow Control** — Added transmission-level chunking (5KB chunks with a 20ms delay) across all platforms. This prevents data loss and printer buffer overflows that previously caused middle sections of long receipts to be blank.
- **Stability**: Added `flush()` calls and small delays between data chunks to give printer hardware time to process high-resolution bitmaps reliably.

# 1.0.1

- **Fix: Chunk-seam artifact on Web** — The previous chunked image approach sent each slice as a separate ESC/POS `GS v 0` command, causing the printer to advance one dot-line between chunks. This produced white horizontal gaps and doubled/ghosted text lines at chunk boundaries. The web implementation now sends the full receipt bitmap as a **single `GS v 0` command**, eliminating all seams.
- **Removed `chunkHeight` from public API** — The `chunkHeight` parameter and `BasePrinterNetworkManager.chunkHeight` getter have been removed. Chunking is now a private implementation detail of the IO (mobile/desktop) path only. The web path does not chunk. This is a **minor breaking change** for anyone passing `chunkHeight` to `PrinterNetworkManager` — simply remove the argument.
- **Screenshot delay increased on Web** — `captureFromLongWidget` delay raised from 200 ms to 500 ms to give fonts additional time to render into the browser canvas before the bitmap is captured.

# 1.0.0

- **Universal Support**: Standardized API for both IO (Mobile/Desktop) and Web platforms.
- **Widget Printing**: Added `printWidget` method to capture and print any Flutter widget as a thermal receipt.
- **High-Performance Isolates**: Utilizes `compute` for image processing to maintain UI thread responsiveness.
- **Chunked Data Support**: Automatic chunking of large images for IO platforms.
- **Extension Status Stream**: Real-time monitoring of the Local TCP Extension availability on Web.
- **Paper Size Support**: Support for 58mm, 72mm, and 80mm paper widths.
- **Improved Networking**: Unified connection handling, timeouts, and error reporting.