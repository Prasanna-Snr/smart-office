import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Reference to the led_status in Firebase
  static DatabaseReference get ledStatusRef => _database.child('led_status');
  
  // Reference to the temperature in Firebase
  static DatabaseReference get temperatureRef => _database.child('temperature');
  
  // Reference to the humidity in Firebase
  static DatabaseReference get humidityRef => _database.child('humidity');
  
  // Update LED status in Firebase
  static Future<void> updateLedStatus(bool status) async {
    try {
      await ledStatusRef.set(status);
      print('LED status updated to: $status');
    } catch (e) {
      print('Error updating LED status: $e');
      throw e;
    }
  }
  
  // Get current LED status from Firebase
  static Future<bool> getLedStatus() async {
    try {
      final snapshot = await ledStatusRef.get();
      if (snapshot.exists) {
        return snapshot.value as bool? ?? false;
      }
      return false;
    } catch (e) {
      print('Error getting LED status: $e');
      return false;
    }
  }
  
  // Listen to LED status changes in real-time
  static Stream<bool> ledStatusStream() {
    return ledStatusRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }
  
  // Get current temperature from Firebase
  static Future<double> getTemperature() async {
    try {
      final snapshot = await temperatureRef.get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 22.0; // Default temperature
    } catch (e) {
      print('Error getting temperature: $e');
      return 22.0;
    }
  }
  
  // Listen to temperature changes in real-time
  static Stream<double> temperatureStream() {
    return temperatureRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 22.0; // Default temperature
    });
  }
  
  // Get current humidity from Firebase
  static Future<double> getHumidity() async {
    try {
      final snapshot = await humidityRef.get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 50.0; // Default humidity
    } catch (e) {
      print('Error getting humidity: $e');
      return 50.0;
    }
  }
  
  // Listen to humidity changes in real-time
  static Stream<double> humidityStream() {
    return humidityRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 50.0; // Default humidity
    });
  }
}