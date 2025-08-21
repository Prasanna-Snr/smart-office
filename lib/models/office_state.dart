class OfficeState {
  bool isDoorOpen;
  bool isLightOn;
  bool isFanOn;
  bool gasDetected;
  int totalUsers;
  double roomTemperature; // in Celsius
  double garbageLevel; // in percentage (0-100)

  OfficeState({
    this.isDoorOpen = false,
    this.isLightOn = false,
    this.isFanOn = false,
    this.gasDetected = false,
    this.totalUsers = 5,
    this.roomTemperature = 22.5,
    this.garbageLevel = 45.0,
  });
}