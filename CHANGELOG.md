# 1.0.0

- **Universal Support**: Standardized API for both IO (Mobile/Desktop) and Web platforms.
- **Widget Printing**: Added `printWidget` method to capture and print any Flutter widget as a thermal receipt.
- **High-Performance Isolates**: Utilizes `compute` for image processing to maintain UI thread responsiveness.
- **Chunked Data Support**: Automatic chunking of large images (default 100px height) specifically optimized for stable web printing via the Chrome Extension bridge.
- **Extension Status Stream**: Real-time monitoring of the Local TCP Extension availability on Web.
- **Paper Size Support**: Exhaustive 지원 for 58mm, 72mm, and 80mm paper widths.
- **Improved Networking**: Unified connection handling, timeouts, and error reporting.