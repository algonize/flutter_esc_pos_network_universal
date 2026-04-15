import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network_universal/flutter_esc_pos_network_universal.dart';

class NetworkPrinter {
  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );
    bytes += generator.text(
      'Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
      styles: const PosStyles(codeTable: 'CP1252'),
    );
    bytes += generator.text(
      'Special 2: blåbærgrød',
      styles: const PosStyles(codeTable: 'CP1252'),
    );

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes += generator.text(
      'Reverse text',
      styles: const PosStyles(reverse: true),
    );
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text(
      'Align left',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Align center',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Align right',
      styles: const PosStyles(align: PosAlign.right),
      linesAfter: 1,
    );

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    bytes += generator.text(
      'Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<void> printTicket(List<int> ticket) async {
    final printer = PrinterNetworkManager('192.168.10.199');
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);
      debugPrint(printing.msg);
      await printer.disconnect();
    } else {
      debugPrint(connect.msg);
    }
  }

  Future<void> printWidgetTicket(BuildContext context) async {
    final printer = PrinterNetworkManager('192.168.10.199');
    final result = await printer.printWidget(
      context,
      child: _TestReciptWidget(pageSize: PaperSize.mm80),
    );
    if (result != PosPrintResult.success) {
      debugPrint(result.msg);
    }
  }
}

class _TestReciptWidget extends StatelessWidget {
  const _TestReciptWidget({required this.pageSize});

  final PaperSize pageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: pageSize.width.toDouble(),
      child: Column(
        children: [
          Text('Thermal POS Printer Test Receipt - ${pageSize.value}'),
          const SizedBox(height: 10),
          const Text(
            'This is a test receipt to demonstrate the capabilities of the thermal POS printer.',
          ),
          const SizedBox(height: 10),
          const Text('Thank you for using our service!'),
        ],
      ),
    );
  }
}
