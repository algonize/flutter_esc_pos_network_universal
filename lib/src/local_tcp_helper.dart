import 'enums.dart';
import 'local_tcp_helper_io.dart' if (dart.library.html) 'local_tcp_helper_web.dart' as platform;

abstract class LocalTcpHelper {
  /// Stream providing updates to the Local TCP Extension status
  static Stream<LocalTcpExtensionStatus> get statusStream => platform.LocalTcpHelperImpl.statusStream;

  /// Trigger a new check of the extension status
  static Future<LocalTcpExtensionStatus> checkStatus() => platform.LocalTcpHelperImpl.checkStatus();

  /// Get the current status (or most recent known status)
  static LocalTcpExtensionStatus get currentStatus => platform.LocalTcpHelperImpl.currentStatus;
}
