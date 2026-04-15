import 'package:example/network_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network_universal/flutter_esc_pos_network_universal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Printer Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize the extension status check
    LocalTcpHelper.checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Printer Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => LocalTcpHelper.checkStatus(),
            tooltip: 'Check Status',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Indicator
            StreamBuilder<LocalTcpExtensionStatus>(
              stream: LocalTcpHelper.statusStream,
              initialData: LocalTcpHelper.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data ?? LocalTcpExtensionStatus.checking;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Extension: ${_getStatusText(status)}',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                await NetworkPrinter().printWidgetTicket(context);
              },
              icon: const Icon(Icons.print),
              label: const Text('Test Print'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LocalTcpExtensionStatus status) {
    switch (status) {
      case LocalTcpExtensionStatus.ready:
        return Colors.green;
      case LocalTcpExtensionStatus.checking:
        return Colors.orange;
      case LocalTcpExtensionStatus.notInstalled:
        return Colors.red;
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return Colors.blue;
      case LocalTcpExtensionStatus.notWeb:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(LocalTcpExtensionStatus status) {
    switch (status) {
      case LocalTcpExtensionStatus.ready:
        return Icons.check_circle;
      case LocalTcpExtensionStatus.checking:
        return Icons.sync;
      case LocalTcpExtensionStatus.notInstalled:
        return Icons.error;
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return Icons.link_off;
      case LocalTcpExtensionStatus.notWeb:
        return Icons.info_outline;
    }
  }

  String _getStatusText(LocalTcpExtensionStatus status) {
    switch (status) {
      case LocalTcpExtensionStatus.ready:
        return 'Ready';
      case LocalTcpExtensionStatus.checking:
        return 'Checking...';
      case LocalTcpExtensionStatus.notInstalled:
        return 'Not Installed';
      case LocalTcpExtensionStatus.bridgeNotLinked:
        return 'Bridge Not Linked';
      case LocalTcpExtensionStatus.notWeb:
        return 'Native Mode';
    }
  }
}
