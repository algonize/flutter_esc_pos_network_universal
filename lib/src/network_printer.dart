import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

import 'enums.dart';
import 'network_printer_interface.dart';
import 'network_printer_io.dart'
    if (dart.library.html) 'network_printer_web.dart' as platform;

/// A universal manager for thermal network printers that works on all Flutter platforms.
///
/// It automatically handles platform-specific communication logic:
/// - **IO (Mobile/Desktop)**: Direct TCP Sockets.
/// - **Web**: Communication via the Local TCP Chrome Extension bridge.
class PrinterNetworkManager implements BasePrinterNetworkManager {
  final BasePrinterNetworkManager _delegate;

  /// Creates a [PrinterNetworkManager] for the given [host].
  ///
  /// - [host]: The IP address of the printer.
  /// - [port]: The TCP port of the printer (default 9100).
  /// - [timeout]: Connection timeout duration (default 5 seconds).
  /// - [paperSize]: The [ThermalPosPrinterPageSize] to use (default 80mm).
  /// - [profile]: Custom [CapabilityProfile] for the printer.
  /// - [chunkHeight]: Height in pixels for image chunking (default 100). Essential for stable web printing.
  PrinterNetworkManager(
    String host, {
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    ThermalPosPrinterPageSize paperSize = ThermalPosPrinterPageSize.size80mm,
    CapabilityProfile? profile,
    int chunkHeight = 100,
  }) : _delegate = platform.createPrinterManager(
          host,
          port,
          timeout,
          paperSize,
          profile,
          chunkHeight,
        );

  /// Returns `true` if currently connected to a printer.
  @override
  bool get isConnected => _delegate.isConnected;

  /// The configured paper size for this manager.
  @override
  ThermalPosPrinterPageSize get paperSize => _delegate.paperSize;

  /// The printer capability profile.
  @override
  CapabilityProfile? get profile => _delegate.profile;

  /// Height in pixels per chunk for image printing.
  @override
  int get chunkHeight => _delegate.chunkHeight;

  /// Attempts to connect to the printer at the configured host and port.
  @override
  Future<PosPrintResult> connect({Duration? timeout}) =>
      _delegate.connect(timeout: timeout);

  /// Disconnects from the printer.
  @override
  Future<PosPrintResult> disconnect({Duration? timeout}) =>
      _delegate.disconnect(timeout: timeout);

  /// Prints a raw list of [data] bytes as an ESC/POS ticket.
  ///
  /// Set [isDisconnect] to `false` if you plan to send more tickets in the same session.
  @override
  Future<PosPrintResult> printTicket(List<int> data,
          {bool isDisconnect = true}) =>
      _delegate.printTicket(data, isDisconnect: isDisconnect);

  /// Captures a Flutter [child] widget and prints it as an image.
  ///
  /// This method uses high-performance [compute] isolates for image processing
  /// and automatically handles chunking for long widgets.
  @override
  Future<PosPrintResult> printWidget(BuildContext context,
          {required Widget child, bool isDisconnect = true}) =>
      _delegate.printWidget(context, child: child, isDisconnect: isDisconnect);
}
