import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/models/experiment_mode.dart';
import '../../core/protocol/device_commands.dart';
import '../../core/serial/serial_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SerialService serial = SerialService();
  StreamSubscription<Uint8List>? subscription;

  List<String> ports = [];
  String? selectedPort;

  int selectedDevice = 1;
  ExperimentMode mode = ExperimentMode.training;

  double delayMs = 200;
  double ledTimeMs = 500;
  bool connected = false;

  bool leftSensor = false;
  bool rightSensor = false;
  bool feederActive = false;

  final List<String> logs = ["Программа запущена"];

  @override
  void initState() {
    super.initState();
    _refreshPorts();
  }

  @override
  void dispose() {
    subscription?.cancel();
    serial.disconnect();
    super.dispose();
  }

  void _refreshPorts() {
    setState(() {
      ports = serial.getAvailablePorts();
      selectedPort = ports.isNotEmpty ? ports.first : null;
    });
    _log("Список COM-портов обновлён");
  }

  void _connect() {
    if (connected) {
      subscription?.cancel();
      serial.disconnect();
      setState(() => connected = false);
      _log("Отключено");
      return;
    }

    if (selectedPort == null) {
      _log("COM-порт не выбран");
      return;
    }

    final ok = serial.connect(selectedPort!);

    if (!ok) {
      _log("Ошибка подключения к $selectedPort");
      return;
    }

    subscription = serial.listen()?.listen(_onDataReceived);

    setState(() => connected = true);
    _log("Подключено к $selectedPort");
  }

  void _onDataReceived(Uint8List data) {
    _log("RX: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

    if (data.length >= 7 && data[0] == 0xAA && data[2] == 0x86) {
      setState(() {
        leftSensor = data[4] == 1;
        rightSensor = data.length > 5 ? data[5] == 1 : false;
        feederActive = data.length > 6 ? data[6] == 1 : false;
      });
    }
  }

  void _send(Uint8List packet, String title) {
    if (!connected) {
      _log("Нет подключения к COM-порту");
      return;
    }

    serial.send(packet);
    _log("$title отправлена");
    _log("TX: ${packet.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
  }

  void _sendStart() {
    _send(
      DeviceCommands.start(address: selectedDevice),
      "Команда START",
    );
  }

  void _sendStop() {
    _send(
      DeviceCommands.stop(address: selectedDevice),
      "Команда STOP",
    );
  }

  void _sendParameters() {
    _send(
      DeviceCommands.setParameters(
        address: selectedDevice,
        delayMs: delayMs.toInt(),
        ledTimeMs: ledTimeMs.toInt(),
      ),
      "Параметры",
    );
  }

  void _sendMode() {
    _send(
      DeviceCommands.setMode(address: selectedDevice, mode: mode),
      "Режим ${mode.title}",
    );
  }

  void _requestStatus() {
    _send(
      DeviceCommands.requestStatus(address: selectedDevice),
      "Запрос статуса",
    );
  }

  void _feedNow() {
    _send(
      DeviceCommands.feedNow(address: selectedDevice),
      "Выдача корма",
    );
  }

  void _resetStats() {
    _send(
      DeviceCommands.resetStatistics(address: selectedDevice),
      "Сброс статистики",
    );
  }

  void _log(String text) {
    setState(() {
      logs.insert(0, "${TimeOfDay.now().format(context)}  $text");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          _sideBar(),
          Expanded(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _summaryCards(),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _deviceStatusCard()),
                            const SizedBox(width: 18),
                            Expanded(child: _controlCard()),
                            const SizedBox(width: 18),
                            Expanded(child: _paramsCard()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _graphCard()),
                            const SizedBox(width: 18),
                            Expanded(child: _logCard()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideBar() {
    return Container(
      width: 280,
      color: const Color(0xFF111827),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Operant Controller",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),

          _label("COM-порт"),
          DropdownButton<String>(
            value: selectedPort,
            dropdownColor: const Color(0xFF1F2937),
            isExpanded: true,
            hint: const Text("Порт не найден"),
            items: ports
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: connected ? null : (v) => setState(() => selectedPort = v),
          ),
          const SizedBox(height: 8),
          _button("Обновить порты", _refreshPorts),
          const SizedBox(height: 8),
          _button(connected ? "Отключиться" : "Подключиться", _connect),

          const SizedBox(height: 24),
          _label("Устройство"),
          DropdownButton<int>(
            value: selectedDevice,
            dropdownColor: const Color(0xFF1F2937),
            isExpanded: true,
            items: List.generate(
              10,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text("Устройство ${i + 1}"),
              ),
            ),
            onChanged: (v) => setState(() => selectedDevice = v!),
          ),

          const SizedBox(height: 24),
          _label("Режим"),
          DropdownButton<ExperimentMode>(
            value: mode,
            dropdownColor: const Color(0xFF1F2937),
            isExpanded: true,
            items: ExperimentMode.values
                .map((m) => DropdownMenuItem(value: m, child: Text(m.title)))
                .toList(),
            onChanged: (v) {
              setState(() => mode = v!);
              _sendMode();
            },
          ),

          const Spacer(),
          Text("Статус: ${connected ? "Подключено" : "Отключено"}"),
          const SizedBox(height: 8),
          const Text("Версия 1.1.0"),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFF020617),
      child: Row(
        children: [
          const Text("Панель управления экспериментом",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.circle,
              color: connected ? Colors.greenAccent : Colors.redAccent,
              size: 12),
          const SizedBox(width: 8),
          Text(connected ? "Подключено: $selectedPort" : "Не подключено"),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(child: _cardInfo("Режим", mode.title, Icons.school)),
        const SizedBox(width: 14),
        Expanded(child: _cardInfo("Устройство", "№ $selectedDevice", Icons.memory)),
        const SizedBox(width: 14),
        Expanded(child: _cardInfo("COM", selectedPort ?? "—", Icons.usb)),
        const SizedBox(width: 14),
        Expanded(child: _cardInfo("Статус", connected ? "Online" : "Offline", Icons.circle)),
      ],
    );
  }

  Widget _deviceStatusCard() {
    return _panel(
      "Состояние устройства",
      Column(
        children: [
          _statusLine("Левый датчик", leftSensor),
          _statusLine("Правый датчик", rightSensor),
          _statusLine("Кормушка", feederActive),
        ],
      ),
    );
  }

  Widget _controlCard() {
    return _panel(
      "Быстрое управление",
      Column(
        children: [
          Row(
            children: [
              Expanded(child: _greenButton("Старт", _sendStart)),
              const SizedBox(width: 10),
              Expanded(child: _redButton("Стоп", _sendStop)),
            ],
          ),
          const SizedBox(height: 12),
          _button("Выдать корм сейчас", _feedNow),
          const SizedBox(height: 10),
          _button("Запросить статус", _requestStatus),
          const SizedBox(height: 10),
          _button("Сброс статистики", _resetStats),
        ],
      ),
    );
  }

  Widget _paramsCard() {
    return _panel(
      "Параметры",
      Column(
        children: [
          _slider("Задержка", delayMs, 0, 2000, (v) => setState(() => delayMs = v)),
          _slider("Свечение", ledTimeMs, 0, 5000, (v) => setState(() => ledTimeMs = v)),
          const SizedBox(height: 12),
          _button("Отправить параметры", _sendParameters),
        ],
      ),
    );
  }

  Widget _graphCard() {
    return _panel(
      "Мониторинг поведения",
      Container(
        height: 250,
        alignment: Alignment.center,
        child: const Text("График событий будет добавлен следующим этапом"),
      ),
    );
  }

  Widget _logCard() {
    return _panel(
      "Лог событий",
      SizedBox(
        height: 250,
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(logs[i], style: const TextStyle(fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _panel(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, IconData icon) {
    return _panel(
      title,
      Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _statusLine(String title, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.circle, size: 14, color: active ? Colors.greenAccent : Colors.redAccent),
          const SizedBox(width: 10),
          Text(title),
          const Spacer(),
          Text(active ? "АКТИВЕН" : "НЕ АКТИВЕН",
              style: TextStyle(color: active ? Colors.greenAccent : Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _slider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title: ${value.toInt()} мс"),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }

  Widget _greenButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget _redButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}
