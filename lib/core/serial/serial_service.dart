import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialService {
  SerialPort? _port;
  SerialPortReader? _reader;

  List<String> getAvailablePorts() {
    return SerialPort.availablePorts;
  }

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

    _reader = SerialPortReader(_port!);
    return true;
  }

  void disconnect() {
    _reader?.close();
    _port?.close();
    _reader = null;
    _port = null;
  }

  bool get isConnected => _port?.isOpen ?? false;

  void send(Uint8List data) {
    if (!isConnected) return;
    _port?.write(data);
  }

  Stream<Uint8List>? listen() {
    return _reader?.stream;
  }
}
