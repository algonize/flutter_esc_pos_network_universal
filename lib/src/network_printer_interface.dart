import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

import 'enums.dart';

abstract class BasePrinterNetworkManager {
  bool get isConnected;
  ThermalPosPrinterPageSize get paperSize;
  CapabilityProfile? get profile;
  int get chunkHeight;

  Future<PosPrintResult> connect({Duration? timeout});
  Future<PosPrintResult> disconnect({Duration? timeout});
  Future<PosPrintResult> printTicket(List<int> data,
      {bool isDisconnect = true});
  Future<PosPrintResult> printWidget(BuildContext context,
      {required Widget child, bool isDisconnect = true});
}
