import 'dart:async';
import 'dart:io';
import '../core/constants/app_constants.dart';

class CameraService {
  // Get current camera stream URL - now uses hardcoded values
  static Future<String> getCameraStreamUrl() async {
    return 'http://${AppConstants.defaultLocalCameraIp}:${AppConstants.defaultCameraPort}${AppConstants.defaultCameraPath}';
  }

  // Test camera connection
  static Future<bool> testCameraConnection(String url) async {
    if (url.isEmpty) return false;
    
    try {
      final client = HttpClient()
        ..connectionTimeout = AppConstants.cameraConnectionTimeout;
      
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      print('Camera connection test failed for $url: $e');
      return false;
    }
  }

  // Find working camera URL - simplified to just test the default URL
  static Future<String?> findWorkingCameraUrl() async {
    final url = await getCameraStreamUrl();
    
    if (await testCameraConnection(url)) {
      print('Found working camera URL: $url');
      return url;
    }

    print('No working camera URL found');
    return null;
  }
}