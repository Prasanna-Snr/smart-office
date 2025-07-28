import 'package:flutter/material.dart';
import '../models/office_state.dart';

class OfficeProvider extends ChangeNotifier {
  OfficeState _officeState = OfficeState();

  OfficeState get officeState => _officeState;

  bool get isDoorOpen => _officeState.isDoorOpen;
  bool get isLightOn => _officeState.isLightOn;
  bool get isFanOn => _officeState.isFanOn;
  bool get gasDetected => _officeState.gasDetected;
  int get totalUsers => _officeState.totalUsers;
  double get roomTemperature => _officeState.roomTemperature;

  void toggleDoor() {
    _officeState.isDoorOpen = !_officeState.isDoorOpen;
    notifyListeners();
  }

  void openDoorWithFaceRecognition() {
    if (!_officeState.isDoorOpen) {
      _officeState.isDoorOpen = true;
      notifyListeners();
    }
  }

  void toggleLight() {
    _officeState.isLightOn = !_officeState.isLightOn;
    // Simulate temperature change when lights are on/off
    _officeState.roomTemperature += _officeState.isLightOn ? 0.5 : -0.5;
    notifyListeners();
  }

  void toggleFan() {
    _officeState.isFanOn = !_officeState.isFanOn;
    // Simulate temperature change when fan is on/off
    _officeState.roomTemperature += _officeState.isFanOn ? -1.0 : 1.0;
    notifyListeners();
  }

  void simulateGasDetection() {
    _officeState.gasDetected = !_officeState.gasDetected;
    notifyListeners();
  }

  void dismissGasAlert() {
    _officeState.gasDetected = false;
    notifyListeners();
  }

  void updateTotalUsers(int users) {
    _officeState.totalUsers = users;
    notifyListeners();
  }

  void updateRoomTemperature(double temperature) {
    _officeState.roomTemperature = temperature;
    notifyListeners();
  }
}