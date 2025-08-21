import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../theme/app_theme.dart';

class TemperatureUtils {
  /// Get color based on temperature value
  static Color getTemperatureColor(double temperature) {
    if (temperature < 18) {
      return Colors.blue; // Too cold
    } else if (temperature >= AppConstants.optimalTempMin && 
               temperature <= AppConstants.optimalTempMax) {
      return AppTheme.successColor; // Optimal
    } else if (temperature > AppConstants.optimalTempMax && temperature <= 28) {
      return AppTheme.warningColor; // Warm
    } else {
      return AppTheme.errorColor; // Too hot
    }
  }
  
  /// Get temperature status text
  static String getTemperatureStatus(double temperature) {
    if (temperature < 18) {
      return 'Too Cold';
    } else if (temperature >= AppConstants.optimalTempMin && 
               temperature <= AppConstants.optimalTempMax) {
      return 'Optimal';
    } else if (temperature > AppConstants.optimalTempMax && temperature <= 28) {
      return 'Warm';
    } else {
      return 'Too Hot';
    }
  }
  
  /// Calculate temperature progress (0.0 to 1.0)
  static double getTemperatureProgress(double temperature) {
    return (temperature - AppConstants.minTemperature) / 
           (AppConstants.maxTemperature - AppConstants.minTemperature);
  }
}