import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/guest/presentation/screens/checkout_screen.dart';
import '../../features/guest/presentation/screens/confirmation_screen.dart';
import '../../features/guest/presentation/screens/error_screen.dart';
import '../../features/guest/presentation/screens/guest_form_screen.dart';
import '../../features/guest/presentation/screens/scan_screen.dart';
import '../../features/location/presentation/screens/dashboard_screen.dart';
import '../../features/location/presentation/screens/guest_list_screen.dart';
import '../../features/location/presentation/screens/qr_generator_screen.dart';
import '../../features/location/presentation/screens/settings_screen.dart';

/// Named route paths used across the app.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String guestList = '/guest-list';
  static const String qrGenerator = '/qr-generator';
  static const String settings = '/settings';
  static const String scan = '/scan';
  static const String guestForm = '/guest-form';
  static const String confirmation = '/confirmation';
  static const String checkout = '/checkout';
  static const String error = '/error';
}

/// Central route generator wired into [MaterialApp.onGenerateRoute].
///
/// Maps each [AppRoutes] name to its screen. Screens that consume data
/// read it from `settings.arguments` internally. Unknown routes fall
/// back to [ErrorScreen].
abstract final class AppRouter {
  /// Builds a [MaterialPageRoute] for the given [settings].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = _pageForRoute(settings.name);
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }

  /// Resolves a route name to its screen widget.
  static Widget _pageForRoute(String? name) {
    switch (name) {
      case AppRoutes.splash:
      case AppRoutes.login:
        return const LoginScreen();
      case AppRoutes.dashboard:
        return const DashboardScreen();
      case AppRoutes.guestList:
        return const GuestListScreen();
      case AppRoutes.qrGenerator:
        return const QrGeneratorScreen();
      case AppRoutes.settings:
        return const SettingsScreen();
      case AppRoutes.scan:
        return const ScanScreen();
      case AppRoutes.guestForm:
        return const GuestFormScreen();
      case AppRoutes.confirmation:
        return const ConfirmationScreen();
      case AppRoutes.checkout:
        return const CheckoutScreen();
      case AppRoutes.error:
      default:
        return const ErrorScreen();
    }
  }
}
