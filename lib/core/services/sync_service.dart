import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/session_logger/presentation/providers/session_providers.dart';

/// Background sync service for offline-first architecture.
/// Monitors connectivity and syncs Hive cache with Firestore when online.
class SyncService {
  final Ref _ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._ref);

  /// Start monitoring connectivity and sync when online
  void startSync() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) async {
        if (_isOnline(result) && !_isSyncing) {
          await _performSync();
        }
      },
    );

    // Initial sync check
    _connectivity.checkConnectivity().then((result) {
      if (_isOnline(result) && !_isSyncing) {
        _performSync();
      }
    });
  }

  /// Stop sync monitoring
  void stopSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  bool _isOnline(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final repository = _ref.read(sessionRepositoryProvider);

      final user = _ref.read(currentUserProvider);
      if (user == null) {
        debugPrint('⚠️ Sync skipped: No authenticated user');
        return;
      }

      // Sync logic happens automatically in repository
      // (Firestore streams update Hive cache)
      // This just triggers a refresh
      await repository.getSessions(user.uid).first;

      debugPrint('✅ Sync completed successfully');
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Force a manual sync
  Future<void> forceSync() async {
    await _performSync();
  }
}

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  service.startSync();

  // Clean up on dispose
  ref.onDispose(() {
    service.stopSync();
  });

  return service;
});

/// Provider for connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider for online status (derived)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.maybeWhen(
    data: (result) =>
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet),
    orElse: () => false,
  );
});
