import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Reference to the led_status in Firebase
  static DatabaseReference get ledStatusRef => _database.child('led_status');

  // Reference to the temperature in Firebase
  static DatabaseReference get temperatureRef => _database.child('temperature');

  // Reference to the humidity in Firebase
  static DatabaseReference get humidityRef => _database.child('humidity');

  // Reference to the garbage level in Firebase
  static DatabaseReference get garbageLevelRef => _database.child('garbage_level');

  // 🔹 Reference to the door status in Firebase
  static DatabaseReference get doorStatusRef => _database.child('door_status');

  // Reference to the fan status in Firebase
  static DatabaseReference get fanStatusRef => _database.child('fan_status');

  // Reference to the automatic mode in Firebase
  static DatabaseReference get automaticModeRef => _database.child('automatic_mode');

  // Reference to the max temperature for automatic fan control
  static DatabaseReference get maxTempRef => _database.child('max_temp');


  // ───────────────── LED ─────────────────
  static Future<void> updateLedStatus(bool status) async {
    try {
      await ledStatusRef.set(status);
      print('LED status updated to: $status');
    } catch (e) {
      print('Error updating LED status: $e');
      throw e;
    }
  }

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

  static Stream<bool> ledStatusStream() {
    return ledStatusRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }

  // ───────────────── Temperature ─────────────────
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

  static Stream<double> temperatureStream() {
    return temperatureRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 22.0;
    });
  }

  // ───────────────── Humidity ─────────────────
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

  static Stream<double> humidityStream() {
    return humidityRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 50.0;
    });
  }

  // ───────────────── Garbage Level ─────────────────
  static Future<void> updateGarbageLevel(double level) async {
    try {
      await garbageLevelRef.set(level);
      print('Garbage level updated to: $level%');
    } catch (e) {
      print('Error updating garbage level: $e');
      throw e;
    }
  }

  static Future<double> getGarbageLevel() async {
    try {
      final snapshot = await garbageLevelRef.get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 45.0;
    } catch (e) {
      print('Error getting garbage level: $e');
      return 45.0;
    }
  }

  static Stream<double> garbageLevelStream() {
    return garbageLevelRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 45.0;
    });
  }

  // ───────────────── Door Status ─────────────────
  static Future<void> updateDoorStatus(bool isOpen) async {
    try {
      await doorStatusRef.set(isOpen);
      print('Door status updated to: ${isOpen ? "OPEN" : "CLOSED"}');
    } catch (e) {
      print('Error updating door status: $e');
      throw e;
    }
  }

  static Future<bool> getDoorStatus() async {
    try {
      final snapshot = await doorStatusRef.get();
      if (snapshot.exists) {
        return snapshot.value as bool? ?? false;
      }
      return false; // Default closed
    } catch (e) {
      print('Error getting door status: $e');
      return false;
    }
  }

  static Stream<bool> doorStatusStream() {
    return doorStatusRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }

  // ───────────────── Fan Status ─────────────────
  static Future<void> updateFanStatus(bool status) async {
    try {
      await fanStatusRef.set(status);
      print('Fan status updated to: $status');
    } catch (e) {
      print('Error updating fan status: $e');
      throw e;
    }
  }

  static Future<bool> getFanStatus() async {
    try {
      final snapshot = await fanStatusRef.get();
      if (snapshot.exists) {
        return snapshot.value as bool? ?? false;
      }
      return false;
    } catch (e) {
      print('Error getting fan status: $e');
      return false;
    }
  }

  static Stream<bool> fanStatusStream() {
    return fanStatusRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }

  // ───────────────── Automatic Mode ─────────────────
  static Future<void> updateAutomaticMode(bool enabled) async {
    try {
      await automaticModeRef.set(enabled);
      print('Automatic mode updated to: $enabled');
    } catch (e) {
      print('Error updating automatic mode: $e');
      throw e;
    }
  }

  static Future<bool> getAutomaticMode() async {
    try {
      final snapshot = await automaticModeRef.get();
      if (snapshot.exists) {
        return snapshot.value as bool? ?? false;
      }
      return false;
    } catch (e) {
      print('Error getting automatic mode: $e');
      return false;
    }
  }

  static Stream<bool> automaticModeStream() {
    return automaticModeRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }

  // ───────────────── Max Temperature ─────────────────
  static Future<void> updateMaxTemp(double temperature) async {
    try {
      await maxTempRef.set(temperature);
      print('Max temperature updated to: $temperature°C');
    } catch (e) {
      print('Error updating max temperature: $e');
      throw e;
    }
  }

  static Future<double> getMaxTemp() async {
    try {
      final snapshot = await maxTempRef.get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 25.0; // Default temperature
    } catch (e) {
      print('Error getting max temperature: $e');
      return 25.0;
    }
  }

  static Stream<double> maxTempStream() {
    return maxTempRef.onValue.map((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value;
        if (value is num) {
          return value.toDouble();
        }
      }
      return 25.0;
    });
  }
}
