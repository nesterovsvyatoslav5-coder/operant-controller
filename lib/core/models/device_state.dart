class DeviceState {
  final bool leftSensor;
  final bool rightSensor;
  final bool feederActive;

  const DeviceState({
    required this.leftSensor,
    required this.rightSensor,
    required this.feederActive,
  });

  factory DeviceState.initial() {
    return const DeviceState(
      leftSensor: false,
      rightSensor: false,
      feederActive: false,
    );
  }
}
