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

  double delayMs = 200;
  double ledTimeMs = 500;

  ExperimentMode mode = ExperimentMode.training;

  bool leftSensor = false;
  bool rightSensor = false;
  bool feederActive = false;

  void _sendStart() {
    final packet = DeviceCommands.start(
      address: selectedDevice,
    );

    debugPrint("START PACKET: $packet");
  }

  void _sendStop() {
    final packet = DeviceCommands.stop(
      address: selectedDevice,
    );

    debugPrint("STOP PACKET: $packet");
  }

  void _sendParameters() {
    final packet = DeviceCommands.setParameters(
      address: selectedDevice,
      delayMs: delayMs.toInt(),
      ledTimeMs: ledTimeMs.toInt(),
    );

    debugPrint("PARAM PACKET: $packet");
  }

  void _sendMode() {
    final packet = DeviceCommands.setMode(
      address: selectedDevice,
      mode: mode,
    );

    debugPrint("MODE PACKET: $packet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operant Controller"),
      ),
      body: Row(
        children: [
          Container(
            width: 260,
            color: Colors.black12,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Устройства",
                  style: TextStyle(fontSize: 22),
                ),

                const SizedBox(height: 20),

                DropdownButton<int>(
                  value: selectedDevice,
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text("Устройство ${index + 1}"),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedDevice = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                DropdownButton<ExperimentMode>(
                  value: mode,
                  items: ExperimentMode.values.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      mode = value!;
                    });

                    _sendMode();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Параметры эксперимента",
                    style: TextStyle(fontSize: 28),
                  ),

                  const SizedBox(height: 20),

                  Text("Задержка: ${delayMs.toInt()} мс"),

                  Slider(
                    value: delayMs,
                    min: 0,
                    max: 2000,
                    onChanged: (value) {
                      setState(() {
                        delayMs = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Text("Время свечения: ${ledTimeMs.toInt()} мс"),

                  Slider(
                    value: ledTimeMs,
                    min: 0,
                    max: 5000,
                    onChanged: (value) {
                      setState(() {
                        ledTimeMs = value;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _sendParameters,
                        child: const Text("Установить параметры"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: _sendStart,
                        child: const Text("Старт"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: _sendStop,
                        child: const Text("Стоп"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Состояние датчиков",
                    style: TextStyle(fontSize: 24),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _buildIndicator(
                        "Левый датчик",
                        leftSensor,
                      ),

                      const SizedBox(width: 20),

                      _buildIndicator(
                        "Правый датчик",
                        rightSensor,
                      ),

                      const SizedBox(width: 20),

                      _buildIndicator(
                        "Кормушка",
                        feederActive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String title, bool active) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(height: 8),

        Text(title),
      ],
    );
  }
}
