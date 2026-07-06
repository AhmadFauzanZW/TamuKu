import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Banner widget that displays when the device is offline.
///
/// Shows an amber-colored bar with a message and optional retry button.
/// Uses [StreamBuilder] on [Connectivity.onConnectivityChanged] to
/// automatically show/hide based on network status.
class ConnectivityBanner extends StatelessWidget {
  /// Creates a [ConnectivityBanner].
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final isOffline =
            results.isEmpty || results.every((r) => r == ConnectivityResult.none);

        if (!isOffline) return const SizedBox.shrink();

        return Material(
          color: Colors.amber.shade700,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tidak ada koneksi internet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menunggu koneksi...'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
