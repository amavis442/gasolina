// ABOUTME: AppBar widget that shows current sync state and triggers manual sync
// ABOUTME: Shows a SnackBar with the error message whenever sync fails

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';

class SyncStatusIndicator extends ConsumerStatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  ConsumerState<SyncStatusIndicator> createState() =>
      _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends ConsumerState<SyncStatusIndicator> {
  @override
  void initState() {
    super.initState();
    // Listen for error transitions and surface them as a SnackBar
    ref.listenManual(syncStateProvider, (previous, next) {
      next.whenOrNull(
        error: (message, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: $message'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () =>
                    ref.read(syncStateProvider.notifier).reset(),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);
    final configAsync = ref.watch(syncConfigProvider);

    return configAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (config) {
        if (!config.isConfigured) return const SizedBox.shrink();

        return syncState.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => IconButton(
            icon: const Icon(Icons.sync_problem),
            tooltip: 'Sync failed — tap to retry',
            onPressed: () =>
                ref.read(syncStateProvider.notifier).triggerSync(config),
          ),
          data: (lastSynced) => IconButton(
            icon: const Icon(Icons.sync),
            tooltip: lastSynced != null
                ? 'Last synced: ${_format(lastSynced)}. Tap to sync.'
                : 'Tap to sync',
            onPressed: () =>
                ref.read(syncStateProvider.notifier).triggerSync(config),
          ),
        );
      },
    );
  }

  String _format(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
