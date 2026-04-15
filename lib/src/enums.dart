import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

enum PosPrintResult {
  success('Success'),
  timeout('Error. Printer connection timeout'),
  printerConnected('Error. Printer not connected'),
  ticketEmpty('Error. Ticket is empty'),
  printInProgress('Error. Another print in progress'),
  scanInProgress('Error. Printer scanning in progress'),
  connectionRefused('Error. Printer connection refused'),
  socketError('Error. Socket error'),
  disconnectError('Error. Failed to disconnect'),
  unknown('Unknown error');

  const PosPrintResult(this.msg);
  final String msg;
}

enum LocalTcpExtensionStatus {
  checking,
  notInstalled,
  bridgeNotLinked,
  ready,
  notWeb,
}

enum ThermalPosPrinterPageSize {
  size58mm('58mm'),
  size72mm('72mm'),
  size80mm('80mm');

  const ThermalPosPrinterPageSize(this.title);
  final String title;
}

extension ThermalPosPrinterPageSizeStringExt on String {
  ThermalPosPrinterPageSize get toThermalPosPrinterPageSize {
    switch (this) {
      case '58mm':
        return ThermalPosPrinterPageSize.size58mm;
      case '72mm':
        return ThermalPosPrinterPageSize.size72mm;
      case '80mm':
        return ThermalPosPrinterPageSize.size80mm;
      default:
        return ThermalPosPrinterPageSize.size80mm;
    }
  }
}

extension ThermalPosPrinterPageSizeExt on ThermalPosPrinterPageSize {
  double get widthPx {
    switch (this) {
      case ThermalPosPrinterPageSize.size58mm:
        return 384.0;
      case ThermalPosPrinterPageSize.size72mm:
        return 512.0;
      case ThermalPosPrinterPageSize.size80mm:
        return 576.0;
    }
  }

  /// Maps the custom enum to the standard PaperSize used by the underlying generator.
  PaperSize get toPaperSize {
    switch (this) {
      case ThermalPosPrinterPageSize.size58mm:
        return PaperSize.mm58;
      case ThermalPosPrinterPageSize.size72mm:
        return PaperSize.mm80;
      case ThermalPosPrinterPageSize.size80mm:
        return PaperSize.mm80;
    }
  }
}

extension LocalTcpExtensionStatusX on LocalTcpExtensionStatus {
  bool get isChecking => this == LocalTcpExtensionStatus.checking;
  bool get isNotInstalled => this == LocalTcpExtensionStatus.notInstalled;
  bool get isBridgeNotLinked => this == LocalTcpExtensionStatus.bridgeNotLinked;
  bool get isReady => this == LocalTcpExtensionStatus.ready;
  bool get isNotWeb => this == LocalTcpExtensionStatus.notWeb;
}
