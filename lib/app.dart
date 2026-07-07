import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/services/sync_queue_service.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'shared/blocs/settings/settings_cubit.dart';
import 'shared/blocs/settings/settings_state.dart';
import 'shared/widgets/connectivity_banner.dart';

/// Root application widget for TamuKu.
///
/// Wraps [MaterialApp] with connectivity listener that shows
/// [ConnectivityBanner], triggers sync when back online, and
/// toggles [ThemeMode] based on [SettingsCubit] state.
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
    return BlocProvider(
      create: (_) => SettingsCubit(prefs: di.getIt<SharedPreferences>()),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsState.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context),
                child: Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ConnectivityBanner(),
                    ),
                  ],
                ),
              );
            },
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
