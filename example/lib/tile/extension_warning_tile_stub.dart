import 'package:flutter/material.dart';

class ExtensionWarningTile extends StatelessWidget {
  const ExtensionWarningTile({
    super.key,
    this.hideWhileLoadingAndReady = false,
  });

  final bool hideWhileLoadingAndReady;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
