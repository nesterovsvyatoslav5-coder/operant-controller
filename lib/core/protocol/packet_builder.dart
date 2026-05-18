import 'dart:typed_data';

class PacketBuilder {
  static const int startByte = 0xAA;
  static const int endByte = 0x55;

  static Uint8List buildPacket({
    required int address,
    required int command,
    required List<int> data,
  }) {
    final length = data.length;

    final packet = <int>[
      startByte,
      address,
      command,
      length,
      ...data,
    ];

    int crc = _calculateCRC(packet.sublist(1));
    packet.add(crc);

    packet.add(endByte);

    return Uint8List.fromList(packet);
  }

  static int _calculateCRC(List<int> bytes) {
    int crc = 0;

    for (final byte in bytes) {
      crc ^= byte;

      for (int i = 0; i < 8; i++) {
        if ((crc & 0x80) != 0) {
          crc = (crc << 1) ^ 0x07;
        } else {
          crc <<= 1;
        }

        crc &= 0xFF;
      }
    }

    return crc;
  }
}
