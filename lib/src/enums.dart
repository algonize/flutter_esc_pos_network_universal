class PosPrintResult {
  const PosPrintResult._internal(this.value);
  final int value;
  static const success = PosPrintResult._internal(1);
  static const timeout = PosPrintResult._internal(2);
  static const printerConnected = PosPrintResult._internal(3);
  static const ticketEmpty = PosPrintResult._internal(4);
  static const printInProgress = PosPrintResult._internal(5);
  static const scanInProgress = PosPrintResult._internal(6);
  static const connectionRefused = PosPrintResult._internal(7);
  static const socketError = PosPrintResult._internal(8);
  static const disconnectError = PosPrintResult._internal(9);

  String get msg {
    if (value == PosPrintResult.success.value) {
      return 'Success';
    } else if (value == PosPrintResult.timeout.value) {
      return 'Error. Printer connection timeout';
    } else if (value == PosPrintResult.printerConnected.value) {
      return 'Error. Printer not connected';
    } else if (value == PosPrintResult.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (value == PosPrintResult.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (value == PosPrintResult.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else if (value == PosPrintResult.connectionRefused.value) {
      return 'Error. Printer connection refused';
    } else if (value == PosPrintResult.socketError.value) {
      return 'Error. Socket error';
    } else if (value == PosPrintResult.disconnectError.value) {
      return 'Error. Failed to disconnect';
    } else {
      return 'Unknown error';
    }
  }
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
        return ThermalPosPrinterPageSize.size58mm;
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
}
