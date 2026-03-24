import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSyncStatus {
  const AppSyncStatus({
    this.isOffline = false,
    this.isSyncing = false,
  });

  final bool isOffline;
  final bool isSyncing;

  AppSyncStatus copyWith({
    bool? isOffline,
    bool? isSyncing,
  }) {
    return AppSyncStatus(
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class SyncStatusController extends StateNotifier<AppSyncStatus> {
  SyncStatusController([AppSyncStatus? initialState])
      : super(initialState ?? const AppSyncStatus());

  void setOffline() {
    state = state.copyWith(
      isOffline: true,
      isSyncing: false,
    );
  }

  void beginSync() {
    state = state.copyWith(
      isOffline: false,
      isSyncing: true,
    );
  }

  void setOnline() {
    state = const AppSyncStatus();
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusController, AppSyncStatus>((ref) {
  return SyncStatusController();
});
