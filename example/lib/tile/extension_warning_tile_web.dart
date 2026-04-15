import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/local_tcp_extension_provider.dart';

class ExtensionWarningTile extends ConsumerWidget {
  const ExtensionWarningTile({super.key, this.hideWhileLoadingAndReady = false});

  final bool hideWhileLoadingAndReady;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(localTcpExtensionProvider);
    final notifier = ref.read(localTcpExtensionProvider.notifier);

    // Only show issues or success on Web
    if (status.isNotWeb) return const SizedBox.shrink();
    if (hideWhileLoadingAndReady && status.isChecking) return const SizedBox.shrink();
    if (hideWhileLoadingAndReady && status.isReady) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: status.color.withValues(alpha: 0.005),
        border: Border(
          left: BorderSide(color: status.color, width: 5),
          right: BorderSide(color: status.color, width: 0.5),
          top: BorderSide(color: status.color, width: 0.5),
          bottom: BorderSide(color: status.color, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: status.color.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(status.icon, color: status.color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      status.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                  ),
                  if (status.isChecking)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.amber),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () async => await notifier.checkStatus(),
                      icon: Icon(Icons.wifi_protected_setup_rounded, size: 20, color: status.color),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Refresh Connection',
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status.isReady)
                    Text(
                      'Your browser can now talk with local TCP.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                        children: status.isNotInstalled
                            ? [
                                const TextSpan(
                                  text: 'To enable web printing, you must install the ',
                                ),
                                TextSpan(
                                  text: 'Local TCP extension',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: status.color,
                                  ),
                                ),
                                const TextSpan(text: ' from the '),
                                const TextSpan(
                                  text: 'Chrome Web Store',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text:
                                      '. This allows secure communication between the browser and your printer.',
                                ),
                              ]
                            : [
                                const TextSpan(text: 'The extension is '),
                                TextSpan(
                                  text: 'Active',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: status.color,
                                  ),
                                ),
                                const TextSpan(text: ', but your '),
                                TextSpan(
                                  text: 'local hardware bridge',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: status.color,
                                  ),
                                ),
                                const TextSpan(text: ' is disconnected. Please ensure the '),
                                const TextSpan(
                                  text: 'setup script',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ' is running on your computer.'),
                              ],
                      ),
                    ),
                  if (!status.isReady) ...[
                    const SizedBox(height: 8),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async => await externalLaunchUrl(notifier.extensionUrl),
                            icon: Icon(
                              status.isNotInstalled
                                  ? Icons.download_rounded
                                  : Icons.settings_rounded,
                              size: 18,
                            ),
                            label: Text(
                              status.isNotInstalled ? 'Get Extension' : 'Setup Instructions',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (status.isNotInstalled) ...[
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.folder_zip_rounded,
                            tooltip: 'Download ZIP',
                            onTap: () async => await externalLaunchUrl(notifier.githubUrl),
                          ),
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.play_circle_fill_rounded,
                            tooltip: 'Setup Video',
                            iconColor: Colors.red,
                            onTap: () async => await externalLaunchUrl(notifier.youtubeUrl),
                          ),
                        ],
                      ],
                    ),
                    if (status.isNotInstalled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Manual Step: Download ZIP → Unzip → chrome://extensions → Load Unpacked',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}

Future<void> externalLaunchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    debugPrint('Could not launch $url');
  }
}
