import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Utility class for retrieving device-specific information
/// Used for device identification and session tracking
class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Retrieves a unique device identifier
  /// 
  /// Platform-specific implementations:
  /// - iOS: Uses identifierForVendor (IDFV) - persists across app reinstalls
  /// - Android: Uses androidId - unique to device
  /// - Web/Desktop: Generates timestamp-based fallback
  /// 
  /// Returns a unique string identifier for the current device
  static Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        // Web doesn't have a reliable device ID
        return _generateFallbackId();
      }
      
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final idfv = iosInfo.identifierForVendor;
        
        if (idfv != null && idfv.isNotEmpty) {
          return idfv;
        } else {
          debugPrint('Warning: iOS identifierForVendor is null, using fallback');
          return _generateFallbackId();
        }
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Android ID
      } else {
        // Other platforms (Windows, macOS, Linux)
        return _generateFallbackId();
      }
    } catch (e) {
      debugPrint('Error retrieving device ID: $e');
      return _generateFallbackId();
    }
  }

  /// Generates a fallback UUID based on timestamp
  /// Note: This should ideally be stored in SharedPreferences for persistence
  /// TODO: Implement persistent storage for fallback IDs
  static String _generateFallbackId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = timestamp.hashCode.toRadixString(36);
    return 'fallback_$timestamp$randomSuffix';
  }

  /// Get device model name
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      }
      return 'Unknown';
    } catch (e) {
      debugPrint('Error retrieving device model: $e');
      return 'Unknown';
    }
  }

  /// Get device platform name
  static Future<String> getDevicePlatform() async {
    try {
      if (Platform.isIOS) {
        return 'iOS';
      } else if (Platform.isAndroid) {
        return 'Android';
      } else if (Platform.isMacOS) {
        return 'macOS';
      } else if (Platform.isWindows) {
        return 'Windows';
      } else if (Platform.isLinux) {
        return 'Linux';
      }
      return 'Unknown';
    } catch (e) {
      debugPrint('Error retrieving platform: $e');
      return 'Unknown';
    }
  }
}
