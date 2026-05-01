// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

import 'enums.dart';
import 'network_printer_interface.dart';

class PrinterNetworkManagerIO implements BasePrinterNetworkManager {
  final String _host;
  final int _port;
  final Duration _timeout;
  final ThermalPosPrinterPageSize _paperSize;
  final int _chunkHeight;
  CapabilityProfile? _profile;

  Socket? _socket;
  bool _isConnected = false;
  bool _isPrinting = false;

  PrinterNetworkManagerIO(
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
        _chunkHeight = chunkHeight;

  @override
  bool get isConnected => _isConnected;

  @override
  ThermalPosPrinterPageSize get paperSize => _paperSize;

  @override
  CapabilityProfile? get profile => _profile;

  @override
  Future<PosPrintResult> connect({Duration? timeout}) async {
    if (_socket != null) {
      await _closeSocket();
    }

    try {
      _socket = await Socket.connect(_host, _port, timeout: timeout ?? _timeout);
      _isConnected = true;
      _profile ??= await CapabilityProfile.load();
      return PosPrintResult.success;
    } on SocketException catch (e) {
      _isConnected = false;
      _socket = null;
      if (e.osError?.errorCode == 61 || e.osError?.errorCode == 111) {
        return PosPrintResult.connectionRefused;
      }
      return PosPrintResult.timeout;
    } catch (e) {
      _isConnected = false;
      _socket = null;
      return PosPrintResult.socketError;
    }
  }

  @override
  Future<PosPrintResult> printTicket(List<int> data, {bool isDisconnect = true}) async {
    if (_isPrinting) {
      return PosPrintResult.printInProgress;
    }

    if (data.isEmpty) {
      return PosPrintResult.ticketEmpty;
    }

    _isPrinting = true;
    try {
      if (!_isConnected || _socket == null) {
        final connectResult = await connect();
        if (connectResult != PosPrintResult.success) {
          _isPrinting = false;
          return connectResult;
        }
      }

      // ── Transmission-level Chunking ─────────────────────────────────────────
      // We send the raw bytes in smaller chunks to ensure the printer's input
      // buffer doesn't overflow.
      const int chunkSize = 5000;
      int offset = 0;

      while (offset < data.length) {
        int end = offset + chunkSize;
        if (end > data.length) end = data.length;

        _socket!.add(data.sublist(offset, end));
        await _socket!.flush();

        offset = end;
        // Small breathing room for the printer's processor
        await Future.delayed(const Duration(milliseconds: 20));
      }

      if (isDisconnect) {
        final disconnectResult = await disconnect();
        if (disconnectResult != PosPrintResult.success) {
          _isPrinting = false;
          return disconnectResult;
        }
      }

      _isPrinting = false;
      return PosPrintResult.success;
    } on SocketException {
      _isPrinting = false;
      await _closeSocket();
      return PosPrintResult.socketError;
    } catch (e) {
      _isPrinting = false;
      await _closeSocket();
      return PosPrintResult.socketError;
    }
  }

  @override
  Future<PosPrintResult> printWidget(BuildContext context,
      {required Widget child, bool isDisconnect = true}) async {
    if (_isPrinting) {
      return PosPrintResult.printInProgress;
    }

    try {
      if (_profile == null) {
        final connectResult = await connect();
        if (connectResult != PosPrintResult.success) {
          return connectResult;
        }
      }

      final ScreenshotController screenshotController = ScreenshotController();

      final Uint8List imageBytes = await screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(context, Material(color: Colors.white, child: child)),
        delay: const Duration(milliseconds: 200),
        context: context,
      );

      final List<int> bytes = await compute(_generateEscPosBytes, {
        'imageBytes': imageBytes,
        'paperSize': _paperSize,
        'profile': _profile!,
        'chunkHeight': _chunkHeight,
      });

      if (bytes.isEmpty) return PosPrintResult.ticketEmpty;

      return await printTicket(bytes, isDisconnect: isDisconnect);
    } catch (e) {
      return PosPrintResult.ticketEmpty;
    }
  }

  static List<int> _generateEscPosBytes(Map<String, dynamic> params) {
    try {
      final Uint8List imageBytes = params['imageBytes'];
      final ThermalPosPrinterPageSize paperSize = params['paperSize'];
      final CapabilityProfile profile = params['profile'];
      final int chunkHeight = params['chunkHeight'];

      final img.Image? baseImage = img.decodeImage(imageBytes);
      if (baseImage == null) return [];

      final generator = Generator(paperSize.toPaperSize, profile);
      List<int> bytes = [];

      // Send the entire image as ONE ESC/POS command to avoid gaps between chunks.
      bytes.addAll(generator.image(baseImage));

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return bytes;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PosPrintResult> disconnect({Duration? timeout}) async {
    try {
      if (_socket != null) {
        await _socket!.flush();
        await _socket!.close();
      }
      _socket = null;
      _isConnected = false;
      if (timeout != null) {
        await Future.delayed(timeout, () => null);
      }
      return PosPrintResult.success;
    } catch (e) {
      _socket = null;
      _isConnected = false;
      return PosPrintResult.disconnectError;
    }
  }

  Future<void> _closeSocket() async {
    try {
      await _socket?.close();
    } catch (_) {}
    _socket = null;
    _isConnected = false;
  }
}

BasePrinterNetworkManager createPrinterManager(
  String host,
  int port,
  Duration timeout,
  ThermalPosPrinterPageSize paperSize,
  CapabilityProfile? profile,
) =>
    PrinterNetworkManagerIO(
      host,
      port: port,
      timeout: timeout,
      paperSize: paperSize,
      profile: profile,
    );
