import 'dart:convert';
import 'dart:io';

import '../constants/app_constants.dart';

class ImageUtils {
  /// Compress image if it exceeds the maximum size
  static Future<List<int>> compressImage(List<int> imageBytes) async {
    try {
      if (imageBytes.length > AppConstants.maxImageSize) {
        // Simple compression by truncating - not ideal but prevents server crashes
        return imageBytes.take(AppConstants.maxImageSize).toList();
      }
      return imageBytes;
    } catch (e) {
      return imageBytes;
    }
  }
  
  /// Convert base64 string to image bytes
  static List<int> base64ToBytes(String base64String) {
    String cleanBase64 = base64String;
    if (cleanBase64.contains(',')) {
      cleanBase64 = cleanBase64.split(',').last;
    }
    return base64Decode(cleanBase64);
  }
  
  /// Create temporary file from base64 data
  static Future<File> createTempFileFromBase64(String base64String) async {
    final imageBytes = base64ToBytes(base64String);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageBytes);
    return tempFile;
  }
  
  /// Clean up temporary file
  static Future<void> deleteTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}