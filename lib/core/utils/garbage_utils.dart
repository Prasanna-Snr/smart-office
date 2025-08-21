import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../theme/app_theme.dart';

class GarbageUtils {
  /// Get color based on garbage level
  static Color getGarbageLevelColor(double level) {
    if (level < AppConstants.warningGarbageLevel) {
      return AppTheme.successColor; // Safe level
    } else if (level < AppConstants.criticalGarbageLevel) {
      return AppTheme.warningColor; // Warning level
    } else {
      return AppTheme.errorColor; // Critical level
    }
  }
  
  /// Get garbage level status text
  static String getGarbageLevelStatus(double level) {
    if (level < AppConstants.warningGarbageLevel) {
      return 'Normal';
    } else if (level < AppConstants.criticalGarbageLevel) {
      return 'Warning';
    } else {
      return 'Critical';
    }
  }
  
  /// Get garbage level description
  static String getGarbageLevelDescription(double level) {
    if (level < AppConstants.warningGarbageLevel) {
      return 'Dustbin has sufficient space';
    } else if (level < AppConstants.criticalGarbageLevel) {
      return 'Dustbin needs attention soon';
    } else {
      return 'Dustbin requires immediate emptying';
    }
  }
  
  /// Check if garbage level requires alert
  static bool requiresAlert(double level) {
    return level >= AppConstants.warningGarbageLevel;
  }
  
  /// Get appropriate icon for garbage level
  static IconData getGarbageLevelIcon(double level) {
    if (level < AppConstants.warningGarbageLevel) {
      return Icons.delete_outline;
    } else if (level < AppConstants.criticalGarbageLevel) {
      return Icons.delete;
    } else {
      return Icons.warning;
    }
  }
}