import 'dart:async';
import 'enums.dart';

class LocalTcpHelperImpl {
  static final _statusController = StreamController<LocalTcpExtensionStatus>.broadcast();

  static Stream<LocalTcpExtensionStatus> get statusStream => _statusController.stream;

  static LocalTcpExtensionStatus get currentStatus => LocalTcpExtensionStatus.notWeb;

  static Future<LocalTcpExtensionStatus> checkStatus() async {
    _statusController.add(LocalTcpExtensionStatus.notWeb);
    return LocalTcpExtensionStatus.notWeb;
  }
}
