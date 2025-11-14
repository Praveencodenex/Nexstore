import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class AdvancedPermissionService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Request only contacts permission
  static Future<PermissionStatus> requestContactsPermission(BuildContext context) async {
    try {
      var status = await Permission.contacts.status;
      if (status.isDenied) {
        status = await Permission.contacts.request();
      }
      return status;
    } catch (e) {
      debugPrint('Error requesting contacts permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request media permissions (photos, videos, storage)
  static Future<Map<Permission, PermissionStatus>> requestMediaPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 33) {
          // Request photos permission
          var photosStatus = await Permission.photos.status;
          if (photosStatus.isDenied) {
            photosStatus = await Permission.photos.request();
          }
          statuses[Permission.photos] = photosStatus;

          // Request videos permission if photos granted
          if (photosStatus.isGranted) {
            var videosStatus = await Permission.videos.status;
            if (videosStatus.isDenied) {
              videosStatus = await Permission.videos.request();
            }
            statuses[Permission.videos] = videosStatus;
          }
        } else if (androidVersion >= 30) {
          var storageStatus = await Permission.manageExternalStorage.status;
          if (storageStatus.isDenied) {
            storageStatus = await Permission.manageExternalStorage.request();
          }
          statuses[Permission.manageExternalStorage] = storageStatus;
        } else {
          var storageStatus = await Permission.storage.status;
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }
          statuses[Permission.storage] = storageStatus;
        }
      } else if (Platform.isIOS) {
        var photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }
        statuses[Permission.photos] = photosStatus;
      }

      return statuses;
    } catch (e) {
      debugPrint('Error requesting media permissions: $e');
      return statuses;
    }
  }

  /// Request notification permission
  static Future<PermissionStatus> requestNotificationPermission() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
      }
      return status;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if contacts permission is granted
  static Future<bool> hasContactsPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  /// Get platform-specific storage directory
  static Future<String> getStorageDirectory() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 30) {
          final directory = await getApplicationDocumentsDirectory();
          return directory.path;
        } else {
          return '/storage/emulated/0/Download';
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
      throw UnsupportedError('Platform not supported');
    } catch (e) {
      debugPrint('Error getting storage directory: $e');
      rethrow;
    }
  }
}