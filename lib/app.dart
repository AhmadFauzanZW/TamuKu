import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/services/sync_queue_service.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'shared/widgets/connectivity_banner.dart';

/// Root application widget for TamuKu.
///
/// Wraps [MaterialApp] with connectivity listener that shows
/// [ConnectivityBanner] and triggers sync when back online.
class TamuKuApp extends StatefulWidget {
  /// Creates a [TamuKuApp].
  const TamuKuApp({super.key});

  @override
  State<TamuKuApp> createState() => _TamuKuAppState();
}

class _TamuKuAppState extends State<TamuKuApp> {
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOffline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);

      if (_wasOffline && !isOffline) {
        // Back online — process sync queue.
        final syncService = di.getIt<SyncQueueService>();
        syncService.processQueue();
      }

      _wasOffline = isOffline;
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      home: const Scaffold(
        body: Center(child: Text(AppConstants.appName)),
      ),
    );
  }
}
