import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

final localTcpExtensionProvider =
    NotifierProvider<LocalTcpExtensionNotifier, LocalTcpExtensionStatus>(
      LocalTcpExtensionNotifier.new,
    );

class LocalTcpExtensionNotifier extends Notifier<LocalTcpExtensionStatus> {
  StreamSubscription? _subscription;

  @override
  LocalTcpExtensionStatus build() {
    // Clean up if the provider is disposed
    ref.onDispose(() => _subscription?.cancel());

    // Initial status check
    if (kIsWeb) {
      Future.microtask(() => checkStatus());
      return LocalTcpExtensionStatus.checking;
    } else {
      return LocalTcpExtensionStatus.notWeb;
    }
  }

  Future<void> checkStatus() async {
    state = LocalTcpExtensionStatus.checking;
    final String messageId = const Uuid().v4();
    final completer = Completer<LocalTcpExtensionStatus>();

    // Listener for response
    _subscription?.cancel();
    _subscription = html.window.onMessage.listen((event) {
      try {
        final data = event.data;
        if (data is Map &&
            data['source'] == 'localtcp_res' &&
            data['messageId'] == messageId) {
          final response = data['response'];
          if (response is Map && response['success'] == true) {
            if (response['connected'] == true) {
              if (!completer.isCompleted) {
                completer.complete(LocalTcpExtensionStatus.ready);
              }
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

    // Send Ping
    final request = {
      'source': 'localtcp_req',
      'messageId': messageId,
      'action': 'CHECK_BRIDGE',
    };

    html.window.postMessage(request, '*');

    // Timeout logic: if no response in 2 seconds, we assume it's not installed
    try {
      final result = await completer.future.timeout(const Duration(seconds: 2));
      state = result;
    } catch (e) {
      if (!completer.isCompleted) {
        state = LocalTcpExtensionStatus.notInstalled;
      }
    } finally {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  String get extensionUrl =>
      'https://chromewebstore.google.com/detail/local-tcp/ngbakchodnmhndnghhejmocfadjfekkf';

  String get githubUrl =>
      'https://github.com/algonize/local_tcp/archive/refs/heads/main.zip';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=D0Zdp7xysy8';
}

enum LocalTcpExtensionStatus {
  checking,
  notInstalled,
  bridgeNotLinked,
  ready,
  notWeb,
}

extension LocalTcpExtensionStatusX on LocalTcpExtensionStatus {
  bool get isChecking => this == LocalTcpExtensionStatus.checking;
  bool get isNotInstalled => this == LocalTcpExtensionStatus.notInstalled;
  bool get isBridgeNotLinked => this == LocalTcpExtensionStatus.bridgeNotLinked;
  bool get isReady => this == LocalTcpExtensionStatus.ready;
  bool get isNotWeb => this == LocalTcpExtensionStatus.notWeb;

  Color get color {
    switch (this) {
      case LocalTcpExtensionStatus.checking:
        return Colors.blue;
      case LocalTcpExtensionStatus.notInstalled:
        return Colors.red;
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return Colors.amber;
      case LocalTcpExtensionStatus.ready:
        return Colors.green;
      case LocalTcpExtensionStatus.notWeb:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case LocalTcpExtensionStatus.checking:
        return Icons.hourglass_top_rounded;
      case LocalTcpExtensionStatus.notInstalled:
        return Icons.extension_off_rounded;
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return Icons.link_off_rounded;
      case LocalTcpExtensionStatus.ready:
        return Icons.check_circle_rounded;
      case LocalTcpExtensionStatus.notWeb:
        return Icons.web_rounded;
    }
  }

  String get title {
    switch (this) {
      case LocalTcpExtensionStatus.checking:
        return 'Checking';
      case LocalTcpExtensionStatus.notInstalled:
        return 'Extension Required';
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return 'Hardware Bridge Offline';
      case LocalTcpExtensionStatus.ready:
        return 'Local TCP Bridge Linked';
      case LocalTcpExtensionStatus.notWeb:
        return 'Unsupported Platform';
    }
  }
}
