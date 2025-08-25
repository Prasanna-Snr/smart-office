import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/office_provider.dart';
import '../../widgets/camera_view.dart';
import '../../widgets/gas_detector.dart';
import '../../widgets/home/door_control_widget.dart';
import '../../widgets/home/device_controls_widget.dart';
import '../../widgets/home/temperature_widget.dart';
import '../../widgets/home/user_count_widget.dart';
import '../../widgets/home/garbage_level_widget.dart';
import '../../theme/app_theme.dart';
import '../../services/face_lock_service.dart';
import '../staff/Staff_attendance_screen.dart';
import '../user_management/user_management_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _userCount = 0;
  bool _isLoadingUserCount = true;

  @override
  void initState() {
    super.initState();
    _loadUserCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadUserCount();
    }
  }

  Future<void> _loadUserCount() async {
    try {
      final users = await FaceLockService.getAllUsers();
      if (mounted) {
        setState(() {
          _userCount = users.length;
          _isLoadingUserCount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userCount = 0;
          _isLoadingUserCount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfficeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            actions: [
              IconButton(
                onPressed: () => provider.simulateGasDetection(),
                icon: const Icon(Icons.science),
                tooltip: 'Simulate Gas Detection',
              ),
            ],
          ),
          drawer: _buildDrawer(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gas Detection Alert
                  GasDetector(
                    gasDetected: provider.gasDetected,
                    onDismiss: () => provider.dismissGasAlert(),
                  ),


                  // Camera Section
                  _buildSectionTitle('Live Camera'),
                  CameraView(),
                  const SizedBox(height: 24),

                  // Controls Section (Door + Garbage) in same row
                  _buildSectionTitle('Door & Dustbin Status'),
                  Row(
                    children: [
                      Expanded(
                        child: const DoorControlWidget(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GarbageLevelWidget(
                          garbageLevel: provider.garbageLevel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),



                  // Device Controls Section
                  _buildSectionTitle('Device Controls'),
                  const DeviceControlsWidget(),
                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildSectionTitle('Office Statistics'),
                  UserCountWidget(
                    userCount: _userCount,
                    isLoading: _isLoadingUserCount,
                    onRefresh: _loadUserCount,
                  ),
                  const SizedBox(height: 12),
                  TemperatureWidget(
                    temperature: provider.roomTemperature,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _buildDrawer(BuildContext context) {
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
                  AppConstants.appName,
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
            onTap: () => _navigateToUserManagement(),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Staff Attendance'),
            onTap: () => _navigateToStaffAttendance(), // Create this function
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _navigateToSettings(),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToUserManagement() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
    _loadUserCount();
  }

  void _navigateToStaffAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StaffAttendanceScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
