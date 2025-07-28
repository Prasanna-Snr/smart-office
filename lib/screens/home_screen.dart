import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/office_provider.dart';
import '../widgets/camera_view.dart';
import '../widgets/gas_detector.dart';
import '../theme/app_theme.dart';
import '../services/face_lock_service.dart';
import 'user_management_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int realTimeUserCount = 0;
  bool isLoadingUserCount = true;

  @override
  void initState() {
    super.initState();
    _loadRealTimeUserCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user count when returning to this screen
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadRealTimeUserCount();
    }
  }

  Future<void> _loadRealTimeUserCount() async {
    try {
      final users = await FaceLockService.getAllUsers();
      setState(() {
        realTimeUserCount = users.length;
        isLoadingUserCount = false;
      });
    } catch (e) {
      print('Error loading user count: $e');
      setState(() {
        realTimeUserCount = 0;
        isLoadingUserCount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfficeProvider>(
      builder: (context, officeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Smart Office"),
            actions: [
              IconButton(
                onPressed: () {
                  // Simulate gas detection for demo
                  officeProvider.simulateGasDetection();
                },
                icon: const Icon(Icons.science),
                tooltip: 'Simulate Gas Detection',
              ),
            ],
          ),
          drawer: _buildDrawer(context, officeProvider),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gas Detection Alert
                  GasDetector(
                    gasDetected: officeProvider.gasDetected,
                    onDismiss: () => officeProvider.dismissGasAlert(),
                  ),

                  // Camera View Section
                  const Text(
                    'Live Camera Feed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CameraView(
                    onFaceRecognition: () {
                      officeProvider.openDoorWithFaceRecognition();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Face recognized! Door opened.'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Door Control Section
                  const Text(
                    'Door Control',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Door Status Display
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            officeProvider.isDoorOpen ? Icons.door_front_door : Icons.door_front_door_outlined,
                            size: 48,
                            color: officeProvider.isDoorOpen ? AppTheme.successColor : Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Door Status',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: officeProvider.isDoorOpen ? AppTheme.successColor : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              officeProvider.isDoorOpen ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Door Control Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: officeProvider.isDoorOpen ? null : () => officeProvider.toggleDoor(),
                                  icon: const Icon(Icons.lock_open),
                                  label: const Text('Open Door'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.successColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: !officeProvider.isDoorOpen ? null : () => officeProvider.toggleDoor(),
                                  icon: const Icon(Icons.lock),
                                  label: const Text('Close Door'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Controls Section
                  const Text(
                    'Device Controls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Office Lights Control
                  Card(
                    child: SwitchListTile.adaptive(
                      value: officeProvider.isLightOn,
                      onChanged: (value) => officeProvider.toggleLight(),
                      title: const Text('Office Lights'),
                      subtitle: Text(
                        officeProvider.isLightOn ? 'Currently ON' : 'Currently OFF',
                        style: TextStyle(
                          color: officeProvider.isLightOn 
                              ? AppTheme.successColor 
                              : Colors.grey,
                        ),
                      ),
                      secondary: Icon(
                        Icons.lightbulb,
                        color: officeProvider.isLightOn 
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
                      value: officeProvider.isFanOn,
                      onChanged: (value) => officeProvider.toggleFan(),
                      title: const Text('Ceiling Fan'),
                      subtitle: Text(
                        officeProvider.isFanOn ? 'Currently ON' : 'Currently OFF',
                        style: TextStyle(
                          color: officeProvider.isFanOn 
                              ? AppTheme.successColor 
                              : Colors.grey,
                        ),
                      ),
                      secondary: Icon(
                        Icons.air,
                        color: officeProvider.isFanOn 
                            ? AppTheme.primaryColor 
                            : Colors.grey,
                      ),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Office Statistics
                  const Text(
                    'Office Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Users Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 32,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Total Users',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isLoadingUserCount)
                                          const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      isLoadingUserCount 
                                          ? 'Loading...' 
                                          : '$realTimeUserCount registered users',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isLoadingUserCount
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      '$realTimeUserCount',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Room Temperature Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.thermostat,
                                size: 32,
                                color: AppTheme.warningColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Room Temperature',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Optimal range: 20-25°C',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${officeProvider.roomTemperature.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getTemperatureColor(officeProvider.roomTemperature),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Temperature Progress Indicator
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '15°C',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '30°C',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: (officeProvider.roomTemperature - 15) / 15, // Scale from 15-30°C
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTemperatureColor(officeProvider.roomTemperature),
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, OfficeProvider officeProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Smart Office',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              );
              // Refresh user count when returning from User Management
              _loadRealTimeUserCount();
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),

        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 18) {
      return Colors.blue; // Too cold
    } else if (temperature >= 18 && temperature <= 25) {
      return AppTheme.successColor; // Optimal
    } else if (temperature > 25 && temperature <= 28) {
      return AppTheme.warningColor; // Warm
    } else {
      return AppTheme.errorColor; // Too hot
    }
  }
}