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
                onChanged: (value) async {
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
                title: const Text('Office Lights'),
                subtitle: Text(
                  provider.isLightOn ? 'Currently ON' : 'Currently OFF',
                  style: TextStyle(
                    color: provider.isLightOn 
                        ? AppTheme.successColor 
                        : Colors.grey,
                  ),
                ),
                secondary: Icon(
                  Icons.lightbulb,
                  color: provider.isLightOn 
                      ? AppTheme.warningColor 
                      : Colors.grey,
                ),
                activeColor: AppTheme.warningColor,
              ),
            ),
            const SizedBox(height: 8),
            // Ceiling Fan Control
            Card(
              child: SwitchListTile.adaptive(
                value: provider.isFanOn,
                onChanged: (value) => provider.toggleFan(),
                title: const Text('Ceiling Fan'),
                subtitle: Text(
                  provider.isFanOn ? 'Currently ON' : 'Currently OFF',
                  style: TextStyle(
                    color: provider.isFanOn 
                        ? AppTheme.successColor 
                        : Colors.grey,
                  ),
                ),
                secondary: Icon(
                  Icons.air,
                  color: provider.isFanOn 
                      ? AppTheme.primaryColor 
                      : Colors.grey,
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