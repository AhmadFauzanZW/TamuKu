import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity status.
///
/// Used by repositories to implement offline-first strategy:
/// remote-first when online, local cache fallback when offline.
abstract class NetworkInfo {
  /// Returns `true` if the device has an active network connection.
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo] using the `connectivity_plus` package.
///
/// Checks whether at least one connectivity type (WiFi, mobile, etc.)
/// is active. Note: this verifies network availability, not necessarily
/// internet reachability — a captive portal would still report as connected.
class NetworkInfoImpl implements NetworkInfo {
  /// Creates a [NetworkInfoImpl] with an optional [Connectivity] override.
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
