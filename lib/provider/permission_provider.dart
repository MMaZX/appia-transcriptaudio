import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier();
});

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(PermissionState());

  void isPlatform() {
    if (!Platform.isAndroid) {
      return;
    }
  }

  Future<void> checkPermission() async {
    isPlatform();
    final permissions = await Future.wait([
      Permission.storage.status,
      Permission.microphone.status,
    ]);

    state = state.copyWith(
      storage: permissions[0],
      microphone: permissions[1],
    );
  }

  Future<void> requestStorageAccess() async {
    isPlatform();
    try {
      final status = await Permission.storage.request();
      state = state.copyWith(storage: status);
      _requestStatusSettings(status);
    } catch (e) {
      throw Exception("ExceptionPermission: $e");
    }
  }

  Future<void> requestMicrophoneAccess() async {
    isPlatform();
    try {
      final status = await Permission.microphone.request();
      state = state.copyWith(microphone: status);
      _requestStatusSettings(status);
    } catch (e) {
      throw Exception("ExceptionPermission: $e");
    }
  }

  // PERMISSION LOCATION
  _requestStatusSettings(PermissionStatus status) {
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }
}

class PermissionState {
  final PermissionStatus storage;
  final PermissionStatus microphone;

  PermissionState({
    this.storage = PermissionStatus.denied,
    this.microphone = PermissionStatus.denied,
  });

  get locationGranted {
    return storage == PermissionStatus.granted;
  }

  copyWith({
    PermissionStatus? storage,
    PermissionStatus? microphone,
  }) {
    return PermissionState(
      storage: storage ?? this.storage,
      microphone: microphone ?? this.microphone,
    );
  }
}

final observerAppProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});
