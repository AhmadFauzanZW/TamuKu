import 'package:permission_handler/permission_handler.dart';

abstract final class PermissionsUtil {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }
}
