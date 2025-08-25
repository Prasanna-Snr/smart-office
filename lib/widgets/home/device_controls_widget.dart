import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/office_provider.dart';
import '../../theme/app_theme.dart';

class DeviceControlsWidget extends StatelessWidget {
  const DeviceControlsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OfficeProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Office Lights Control
            Card(
              child: SwitchListTile.adaptive(
                value: provider.isLightOn,
                onChanged: provider.isAutomaticModeEnabled ? null : (value) async {
                  try {
                    await provider.toggleLight();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to toggle light. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                title: Text(
                  'Office Lights',
                  style: TextStyle(
                    color: provider.isAutomaticModeEnabled ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  provider.isAutomaticModeEnabled 
                      ? 'Controlled automatically'
                      : (provider.isLightOn ? 'Currently ON' : 'Currently OFF'),
                  style: TextStyle(
                    color: provider.isAutomaticModeEnabled 
                        ? Colors.grey 
                        : (provider.isLightOn ? AppTheme.successColor : Colors.grey),
                  ),
                ),
                secondary: Icon(
                  provider.isAutomaticModeEnabled ? Icons.auto_mode : Icons.lightbulb,
                  color: provider.isAutomaticModeEnabled 
                      ? Colors.grey 
                      : (provider.isLightOn ? AppTheme.warningColor : Colors.grey),
                ),
                activeColor: AppTheme.warningColor,
              ),
            ),
            const SizedBox(height: 8),
            // Ceiling Fan Control
            Card(
              child: SwitchListTile.adaptive(
                value: provider.isFanOn,
                onChanged: provider.isAutomaticModeEnabled ? null : (value) async {
                  try {
                    await provider.toggleFan();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to toggle fan. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                title: Text(
                  'Ceiling Fan',
                  style: TextStyle(
                    color: provider.isAutomaticModeEnabled ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  provider.isAutomaticModeEnabled 
                      ? 'Auto: ${provider.roomTemperature.toStringAsFixed(1)}°C > ${provider.automaticFanTemperature.toStringAsFixed(1)}°C'
                      : (provider.isFanOn ? 'Currently ON' : 'Currently OFF'),
                  style: TextStyle(
                    color: provider.isAutomaticModeEnabled 
                        ? Colors.grey 
                        : (provider.isFanOn ? AppTheme.successColor : Colors.grey),
                  ),
                ),
                secondary: Icon(
                  provider.isAutomaticModeEnabled ? Icons.auto_mode : Icons.air,
                  color: provider.isAutomaticModeEnabled 
                      ? Colors.grey 
                      : (provider.isFanOn ? AppTheme.primaryColor : Colors.grey),
                ),
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}