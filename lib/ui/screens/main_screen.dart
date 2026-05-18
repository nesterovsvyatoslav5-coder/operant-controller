import 'package:flutter/material.dart';

import '../../core/models/experiment_mode.dart';
import '../../core/protocol/device_commands.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedDevice = 1;
  ExperimentMode mode = ExperimentMode.training;

  double delayMs = 200;
  double ledTimeMs = 500;
  double timeoutMs = 3000;
  double trials = 100;

  bool connected = false;
  bool leftSensor = true;
  bool rightSensor = false;
  bool feederActive = true;

  final List<String> logs = [
    "Программа запущена",
    "Ожидание подключения устройства",
  ];

  void _log(String text) {
    setState(() {
      logs.insert(0, "${TimeOfDay.now().format(context)}  $text");
    });
  }

  void _sendStart() {
    final packet = DeviceCommands.start(address: selectedDevice);
    debugPrint("START PACKET: $packet");
    _log("Сессия запущена для устройства $selectedDevice");
  }

  void _sendStop() {
    final packet = DeviceCommands.stop(address: selectedDevice);
    debugPrint("STOP PACKET: $packet");
    _log("Сессия остановлена");
  }

  void _sendParameters() {
    final packet = DeviceCommands.setParameters(
      address: selectedDevice,
      delayMs: delayMs.toInt(),
      ledTimeMs: ledTimeMs.toInt(),
    );
    debugPrint("PARAM PACKET: $packet");
    _log("Параметры отправлены на устройство $selectedDevice");
  }

  void _sendMode() {
    final packet = DeviceCommands.setMode(
      address: selectedDevice,
      mode: mode,
    );
    debugPrint("MODE PACKET: $packet");
    _log("Выбран режим: ${mode.title}");
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
      width: 270,
      color: const Color(0xFF111827),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Operant Controller",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _label("COM-порт"),
          _button(connected ? "Отключиться" : "Подключиться", () {
            setState(() => connected = !connected);
            _log(connected ? "Подключено к COM-порту" : "Отключено");
          }),
          const SizedBox(height: 24),
          _label("Устройства"),
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
          const Text("Версия 1.0.0"),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Color(0xFF020617)),
      child: Row(
        children: [
          const Text("Панель управления экспериментом",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.circle,
              color: connected ? Colors.greenAccent : Colors.redAccent,
              size: 12),
          const SizedBox(width: 8),
          Text(connected ? "Подключено" : "Не подключено"),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(child: _cardInfo("Режим", mode.title, Icons.school)),
        const SizedBox(width: 14),
        Expanded(
            child: _cardInfo("Устройство",
                "№ $selectedDevice", Icons.memory)),
        const SizedBox(width: 14),
        Expanded(child: _cardInfo("Награды", "0", Icons.card_giftcard)),
        const SizedBox(width: 14),
        Expanded(child: _cardInfo("Ошибки", "0", Icons.error_outline)),
      ],
    );
  }

  Widget _deviceStatusCard() {
    return _panel(
      "Состояние устройства",
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _statusLine("Левый датчик", leftSensor),
                _statusLine("Правый датчик", rightSensor),
                _statusLine("Кормушка", feederActive),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.blueGrey.shade700),
              ),
              child: const Center(
                child: Icon(Icons.pets, size: 80, color: Colors.blueAccent),
              ),
            ),
          ),
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
          _button("Выдать корм сейчас", () => _log("Кормушка активирована")),
          const SizedBox(height: 10),
          _button("Запросить статус", () => _log("Запрос состояния отправлен")),
          const SizedBox(height: 10),
          _button("Сброс статистики", () => _log("Статистика сброшена")),
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
          _slider("Таймаут", timeoutMs, 0, 10000, (v) => setState(() => timeoutMs = v)),
          _slider("Кол-во проб", trials, 1, 300, (v) => setState(() => trials = v)),
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
        height: 260,
        alignment: Alignment.center,
        child: const Text(
          "Здесь будет график событий: датчики, награды, ошибки",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _logCard() {
    return _panel(
      "Лог событий",
      SizedBox(
        height: 260,
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
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Icon(icon, color: Colors.blueAccent, size: 32),
          const SizedBox(width: 14),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusLine(String title, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.circle,
              size: 14, color: active ? Colors.greenAccent : Colors.redAccent),
          const SizedBox(width: 10),
          Text(title),
          const Spacer(),
          Text(active ? "АКТИВЕН" : "НЕ АКТИВЕН",
              style: TextStyle(
                  color: active ? Colors.greenAccent : Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _slider(String title, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title: ${value.toInt()}"),
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
      child: Text(text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}
