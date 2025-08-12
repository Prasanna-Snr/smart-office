import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

/// Demo class showing how to use Firebase LED control
class FirebaseLedDemo {
  
  /// Example: Turn LED ON
  static Future<void> turnLedOn() async {
    try {
      await FirebaseService.updateLedStatus(true);
      print('✅ LED turned ON successfully');
    } catch (e) {
      print('❌ Error turning LED ON: $e');
    }
  }
  
  /// Example: Turn LED OFF
  static Future<void> turnLedOff() async {
    try {
      await FirebaseService.updateLedStatus(false);
      print('✅ LED turned OFF successfully');
    } catch (e) {
      print('❌ Error turning LED OFF: $e');
    }
  }
  
  /// Example: Get current LED status
  static Future<void> checkLedStatus() async {
    try {
      final status = await FirebaseService.getLedStatus();
      print('💡 Current LED status: ${status ? 'ON' : 'OFF'}');
    } catch (e) {
      print('❌ Error getting LED status: $e');
    }
  }
  
  /// Example: Listen to LED status changes
  static void listenToLedChanges() {
    FirebaseService.ledStatusStream().listen(
      (bool status) {
        print('🔄 LED status changed to: ${status ? 'ON' : 'OFF'}');
      },
      onError: (error) {
        print('❌ Error listening to LED changes: $error');
      },
    );
  }
}

/// Demo widget showing Firebase LED control
class FirebaseLedDemoWidget extends StatefulWidget {
  const FirebaseLedDemoWidget({super.key});

  @override
  State<FirebaseLedDemoWidget> createState() => _FirebaseLedDemoWidgetState();
}

class _FirebaseLedDemoWidgetState extends State<FirebaseLedDemoWidget> {
  bool _ledStatus = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLedStatus();
    _listenToChanges();
  }

  Future<void> _loadLedStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await FirebaseService.getLedStatus();
      setState(() => _ledStatus = status);
    } catch (e) {
      print('Error loading LED status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _listenToChanges() {
    FirebaseService.ledStatusStream().listen(
      (bool status) {
        if (mounted) {
          setState(() => _ledStatus = status);
        }
      },
    );
  }

  Future<void> _toggleLed() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseService.updateLedStatus(!_ledStatus);
    } catch (e) {
      print('Error toggling LED: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase LED Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _ledStatus ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: _ledStatus ? Colors.yellow : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'LED Status: ${_ledStatus ? 'ON' : 'OFF'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _toggleLed,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_ledStatus ? 'Turn OFF' : 'Turn ON'),
            ),
          ],
        ),
      ),
    );
  }
}