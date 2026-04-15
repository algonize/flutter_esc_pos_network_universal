import 'dart:async';

import 'package:flutter/material.dart';

import 'enums.dart';
import 'network_printer_interface.dart';
import 'network_printer_io.dart' if (dart.library.html) 'network_printer_web.dart' as platform;

class PrinterNetworkManager implements BasePrinterNetworkManager {
  final BasePrinterNetworkManager _delegate;

  PrinterNetworkManager(
    String host, {
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) : _delegate = platform.createPrinterManager(host, port, timeout);

  @override
  bool get isConnected => _delegate.isConnected;

  @override
  Future<PosPrintResult> connect({Duration? timeout}) => _delegate.connect(timeout: timeout);

  @override
  Future<PosPrintResult> disconnect({Duration? timeout}) => _delegate.disconnect(timeout: timeout);

  @override
  Future<PosPrintResult> printTicket(List<int> data, {bool isDisconnect = true}) =>
      _delegate.printTicket(data, isDisconnect: isDisconnect);

  @override
  Future<PosPrintResult> printWidget(BuildContext context, {required Widget child, bool isDisconnect = true}) =>
      _delegate.printWidget(context, child: child, isDisconnect: isDisconnect);
}
