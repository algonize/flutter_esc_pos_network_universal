import 'dart:async';

import 'package:flutter/material.dart';

import 'enums.dart';

abstract class BasePrinterNetworkManager {
  bool get isConnected;

  Future<PosPrintResult> connect({Duration? timeout});
  Future<PosPrintResult> disconnect({Duration? timeout});
  Future<PosPrintResult> printTicket(List<int> data, {bool isDisconnect = true});
  Future<PosPrintResult> printWidget(BuildContext context, {required Widget child, bool isDisconnect = true});
}
