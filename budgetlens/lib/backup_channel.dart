import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class BackupChannel {
  static const MethodChannel _channel = MethodChannel('backup_channel');

  /// Export raw JSON bytes to SAF via Android Intent (ACTION_CREATE_DOCUMENT)
  static Future<void> exportJsonBackup(Uint8List bytes) async {
    await _channel.invokeMethod('exportBackup', bytes);
  }

  /// Import JSON bytes from SAF via Android Intent (ACTION_OPEN_DOCUMENT)
  /// Returns decoded JSON string or null if cancelled.
  static Future<String?> importJsonBackup() async {
    final Uint8List? bytes = await _channel.invokeMethod<Uint8List?>('importBackup');
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }
}
