import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/office_provider.dart';
import '../theme/app_theme.dart';

class LedControlWidget extends StatefulWidget {
  const LedControlWidget({super.key});

  @override
  State<LedControlWidget> createState() => _LedControlWidgetState();
}

class _LedControlWidgetState extends State<LedControlWidget> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OfficeProvider>(
      builder: (context, officeProvider, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Firebase indicator
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 28,
                      color: officeProvider.isLightOn 
                          ? AppTheme.warningColor 
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Office LED Control',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_sync,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Firebase',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Status Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: officeProvider.isLightOn 
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: officeProvider.isLightOn 
                          ? AppTheme.warningColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        officeProvider.isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                        size: 48,
                        color: officeProvider.isLightOn 
                            ? AppTheme.warningColor 
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        officeProvider.isLightOn ? 'LED ON' : 'LED OFF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: officeProvider.isLightOn 
                              ? AppTheme.warningColor 
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time sync with Firebase',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Control Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isToggling ? null : () => _toggleLed(officeProvider),
                    icon: _isToggling 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            officeProvider.isLightOn ? Icons.light_mode : Icons.light_mode_outlined,
                          ),
                    label: Text(
                      _isToggling 
                          ? 'Updating...'
                          : officeProvider.isLightOn 
                              ? 'Turn OFF' 
                              : 'Turn ON',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: officeProvider.isLightOn 
                          ? Colors.red 
                          : AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Info Text
                Text(
                  'This control is synchronized with your Firebase Realtime Database. Changes will be reflected in real-time across all connected devices.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLed(OfficeProvider officeProvider) async {
    setState(() {
      _isToggling = true;
    });

    try {
      await officeProvider.toggleLight();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'LED ${officeProvider.isLightOn ? 'turned ON' : 'turned OFF'} successfully!',
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to toggle LED. Please check your connection.'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }
}