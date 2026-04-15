import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'enums.dart';

class LocalTcpHelperImpl {
  static final _statusController = StreamController<LocalTcpExtensionStatus>.broadcast();
  static LocalTcpExtensionStatus _currentStatus = LocalTcpExtensionStatus.checking;
  static bool _isInitialized = false;

  static Stream<LocalTcpExtensionStatus> get statusStream => _statusController.stream;

  static LocalTcpExtensionStatus get currentStatus => _currentStatus;

  static Future<LocalTcpExtensionStatus> checkStatus() async {
    if (!_isInitialized) {
      _initListener();
    }

    _updateStatus(LocalTcpExtensionStatus.checking);

    final String messageId = const Uuid().v4();
    final completer = Completer<LocalTcpExtensionStatus>();
    StreamSubscription? sub;

    sub = html.window.onMessage.listen((event) {
      try {
        final data = event.data;
        if (data is Map && data['source'] == 'localtcp_res' && data['messageId'] == messageId) {
          final response = data['response'];
          if (response is Map && response['success'] == true) {
            if (response['connected'] == true) {
              if (!completer.isCompleted) completer.complete(LocalTcpExtensionStatus.ready);
            } else {
              if (!completer.isCompleted) {
                completer.complete(LocalTcpExtensionStatus.bridgeNotLinked);
              }
            }
          }
        }
      } catch (e) {
        // Ignore malformed messages
      }
    });

    final request = {
      'source': 'localtcp_req',
      'messageId': messageId,
      'action': 'CHECK_BRIDGE',
    };

    html.window.postMessage(request, '*');

    try {
      final result = await completer.future.timeout(const Duration(seconds: 2));
      _updateStatus(result);
      return result;
    } catch (e) {
      if (!completer.isCompleted) {
        _updateStatus(LocalTcpExtensionStatus.notInstalled);
        return LocalTcpExtensionStatus.notInstalled;
      }
      return _currentStatus;
    } finally {
      sub.cancel();
    }
  }

  static void _initListener() {
    _isInitialized = true;
    // We could potentially listen globally for status updates from the extension here if it pushed them.
  }

  static void _updateStatus(LocalTcpExtensionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
}
