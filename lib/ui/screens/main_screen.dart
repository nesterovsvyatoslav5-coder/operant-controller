import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedDevice = 1;

  double delayMs = 200;
  double ledTimeMs = 500;

  bool leftSensor = false;
  bool rightSensor = false;
  bool feederActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operant Controller"),
      ),
      body: Row(
        children: [
          // Левая панель
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

                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Подключиться"),
                ),
              ],
            ),
          ),

          // Правая часть
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

                  // Delay
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

                  // LED
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
                        onPressed: () {},
                        child: const Text("Старт"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () {},
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
