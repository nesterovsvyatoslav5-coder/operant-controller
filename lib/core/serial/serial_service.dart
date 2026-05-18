import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialService {
  SerialPort? _port;

  bool connect(String portName) {
    _port = SerialPort(portName);

    if (!_port!.openReadWrite()) {
      return false;
    }

    _port!.config = SerialPortConfig()
      ..baudRate = 115200
      ..bits = 8
      ..stopBits = 1
      ..parity = SerialPortParity.none;

    return true;
  }

  void disconnect() {
    _port?.close();
  }

  bool get isConnected => _port?.isOpen ?? false;

  void send(Uint8List data) {
    _port?.write(data);
  }

  Stream<Uint8List> listen() {
    if (_port == null) {
      throw Exception("Port not connected");
    }

    final reader = SerialPortReader(_port!);

    return reader.stream;
  }
}
