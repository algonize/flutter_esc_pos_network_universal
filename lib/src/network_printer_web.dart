// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'network_printer_interface.dart';

class PrinterNetworkManagerWeb implements BasePrinterNetworkManager {
  final String _host;
  final int _port;
  final Duration _timeout;
  final ThermalPosPrinterPageSize _paperSize;
  final int _chunkHeight;
  CapabilityProfile? _profile;

  bool _isConnected = false;
  bool _isPrinting = false;

  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  StreamSubscription? _messageSubscription;

  PrinterNetworkManagerWeb(
    String host, {
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    ThermalPosPrinterPageSize paperSize = ThermalPosPrinterPageSize.size80mm,
    CapabilityProfile? profile,
    int chunkHeight = 100,
  })  : _host = host,
        _port = port,
        _timeout = timeout,
        _paperSize = paperSize,
        _profile = profile,
        _chunkHeight = chunkHeight {
    _initListener();
  }

  void _initListener() {
    _messageSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['source'] == 'localtcp_res') {
        final messageId = data['messageId'];
        final response = data['response'];
        if (messageId != null && _pendingRequests.containsKey(messageId)) {
          _pendingRequests[messageId]!
              .complete(Map<String, dynamic>.from(response));
          _pendingRequests.remove(messageId);
        }
      }
    });
  }

  @override
  bool get isConnected => _isConnected;

  @override
  ThermalPosPrinterPageSize get paperSize => _paperSize;

  @override
  CapabilityProfile? get profile => _profile;

  @override
  int get chunkHeight => _chunkHeight;

  Future<Map<String, dynamic>> _sendMessage(String action,
      {List<int>? data}) async {
    final messageId = const Uuid().v4();
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[messageId] = completer;

    final request = {
      'source': 'localtcp_req',
      'messageId': messageId,
      'action': action,
      'host': _host,
      'port': _port.toString(),
      'data': data,
    };

    html.window.postMessage(request, '*');

    try {
      return await completer.future.timeout(_timeout);
    } catch (e) {
      _pendingRequests.remove(messageId);
      return {'success': false, 'error': 'Request timed out'};
    }
  }

  @override
  Future<PosPrintResult> connect({Duration? timeout}) async {
    final res = await _sendMessage('CONNECT');
    if (res['success'] == true) {
      _isConnected = true;
      _profile ??= await CapabilityProfile.load();
      return PosPrintResult.success;
    }
    return PosPrintResult.socketError;
  }

  @override
  Future<PosPrintResult> disconnect({Duration? timeout}) async {
    await _sendMessage('DISCONNECT');
    _isConnected = false;
    return PosPrintResult.success;
  }

  @override
  Future<PosPrintResult> printTicket(List<int> data,
      {bool isDisconnect = true}) async {
    if (_isPrinting) return PosPrintResult.printInProgress;
    if (data.isEmpty) return PosPrintResult.ticketEmpty;

    _isPrinting = true;
    try {
      final res = await _sendMessage('SEND', data: data);
      _isPrinting = false;

      if (res['success'] == true) {
        if (isDisconnect) await disconnect();
        return PosPrintResult.success;
      } else {
        return PosPrintResult.socketError;
      }
    } catch (e) {
      _isPrinting = false;
      return PosPrintResult.socketError;
    }
  }

  @override
  Future<PosPrintResult> printWidget(BuildContext context,
      {required Widget child, bool isDisconnect = true}) async {
    if (_isPrinting) return PosPrintResult.printInProgress;

    try {
      if (_profile == null) {
        final connectResult = await connect();
        if (connectResult != PosPrintResult.success) {
          return connectResult;
        }
      }

      final ScreenshotController screenshotController = ScreenshotController();
      final imageBytes = await screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
            context, Material(color: Colors.white, child: child)),
        delay: const Duration(milliseconds: 200),
        context: context,
      );

      final img.Image? baseImage = img.decodeImage(imageBytes);
      if (baseImage == null) return PosPrintResult.ticketEmpty;

      final generator = Generator(_paperSize.toPaperSize, _profile!);
      List<int> bytes = [];

      int yOffset = 0;

      while (yOffset < baseImage.height) {
        int h = (yOffset + _chunkHeight > baseImage.height)
            ? baseImage.height - yOffset
            : _chunkHeight;
        final img.Image cropped = img.copyCrop(baseImage,
            x: 0, y: yOffset, width: baseImage.width, height: h);
        bytes.addAll(generator.image(cropped));
        yOffset += h;
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return await printTicket(bytes, isDisconnect: isDisconnect);
    } catch (e) {
      return PosPrintResult.ticketEmpty;
    }
  }

  void dispose() {
    _messageSubscription?.cancel();
  }
}

BasePrinterNetworkManager createPrinterManager(
  String host,
  int port,
  Duration timeout,
  ThermalPosPrinterPageSize paperSize,
  CapabilityProfile? profile,
  int chunkHeight,
) =>
    PrinterNetworkManagerWeb(
      host,
      port: port,
      timeout: timeout,
      paperSize: paperSize,
      profile: profile,
      chunkHeight: chunkHeight,
    );
