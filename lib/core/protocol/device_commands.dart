import 'dart:typed_data';

import '../models/experiment_mode.dart';
import 'command_codes.dart';
import 'packet_builder.dart';

class DeviceCommands {
  static Uint8List setMode({
    required int address,
    required ExperimentMode mode,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.setMode,
      data: [mode.code],
    );
  }

  static Uint8List setParameters({
    required int address,
    required int delayMs,
    required int ledTimeMs,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.setParameters,
      data: [
        delayMs & 0xFF,
        ledTimeMs & 0xFF,
      ],
    );
  }

  static Uint8List start({
    required int address,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.startExperiment,
      data: [0x01],
    );
  }

  static Uint8List stop({
    required int address,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.stopExperiment,
      data: [0x00],
    );
  }

  static Uint8List requestStatus({
    required int address,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.requestStatus,
      data: [],
    );
  }

  static Uint8List feedNow({
    required int address,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.feedNow,
      data: [0x01],
    );
  }

  static Uint8List resetStatistics({
    required int address,
  }) {
    return PacketBuilder.buildPacket(
      address: address,
      command: CommandCodes.resetStatistics,
      data: [0x00],
    );
  }
}
