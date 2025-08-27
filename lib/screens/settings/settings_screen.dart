import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/office_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _temperatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OfficeProvider>(context, listen: false);
    _temperatureController.text = provider.automaticFanTemperature.toString();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OfficeProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Mode Section
              _buildSectionCard(
                title: 'Mode',
                children: [
                  SwitchListTile.adaptive(
                    value: provider.isAutomaticModeEnabled,
                    onChanged: (value) async {
                      try {
                        if (value) {
                          // Show temperature setting dialog when enabling automatic mode
                          final temperature = await _showTemperatureDialog(context, provider.automaticFanTemperature);
                          if (temperature != null) {
                            await provider.setAutomaticFanTemperature(temperature);
                            await provider.toggleAutomaticMode();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Automatic mode enabled. Lights: Motion control, Fan: Temperature > ${temperature.toStringAsFixed(1)}°C'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          }
                        } else {
                          await provider.toggleAutomaticMode();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Automatic mode disabled'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update automatic mode: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    title: const Text(
                      'Enable Automatic Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      provider.isAutomaticModeEnabled
                          ? 'Lights: Motion sensor control\nFan: Temperature > ${provider.automaticFanTemperature.toStringAsFixed(1)}°C'
                          : 'Manual control of all devices',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    secondary: null,
                    activeColor: AppTheme.primaryColor,
                  ),
                  if (provider.isAutomaticModeEnabled)
                    ListTile(
                      leading: null,
                      title: const Text('Fan Temperature Threshold'),
                      subtitle: Text('${provider.automaticFanTemperature.toStringAsFixed(1)}°C'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          try {
                            final temperature = await _showTemperatureDialog(context, provider.automaticFanTemperature);
                            if (temperature != null) {
                              await provider.setAutomaticFanTemperature(temperature);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Temperature threshold updated to ${temperature.toStringAsFixed(1)}°C'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update temperature: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Device Status Section
              _buildSectionCard(
                title: 'Device Status',
                children: [
                  _buildStatusTile(
                    icon: Icons.lightbulb,
                    title: 'Office Lights',
                    status: provider.isLightOn ? 'ON' : 'OFF',
                    isActive: provider.isLightOn,
                  ),
                  const Divider(height: 1),
                  _buildStatusTile(
                    icon: Icons.air,
                    title: 'Ceiling Fan',
                    status: provider.isFanOn ? 'ON' : 'OFF',
                    isActive: provider.isFanOn,
                  ),
                  const Divider(height: 1),
                  _buildStatusTile(
                    icon: Icons.door_front_door,
                    title: 'Door',
                    status: provider.isDoorOpen ? 'OPEN' : 'CLOSED',
                    isActive: provider.isDoorOpen,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<double?> _showTemperatureDialog(BuildContext context, double currentTemp) async {
    _temperatureController.text = currentTemp.toString();
    
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Fan Temperature Threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Fan will turn on automatically when temperature exceeds this value:'),
              const SizedBox(height: 16),
              TextField(
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  border: OutlineInputBorder(),
                  suffixText: '°C',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final temp = double.tryParse(_temperatureController.text);
                if (temp != null && temp >= 15 && temp <= 40) {
                  Navigator.of(context).pop(temp);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid temperature between 15°C and 40°C'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required String title,
    required String status,
    required bool isActive,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.successColor : Colors.grey,
      ),
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.successColor : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


}