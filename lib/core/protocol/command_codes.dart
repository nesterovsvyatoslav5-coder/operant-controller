class CommandCodes {
  // Режимы
  static const int setMode = 0x01;

  // Параметры
  static const int setParameters = 0x02;

  // Управление
  static const int startExperiment = 0x03;
  static const int stopExperiment = 0x04;
  static const int pauseExperiment = 0x05;

  // Статус
  static const int requestStatus = 0x06;
  static const int statusResponse = 0x86;

  // Управление кормушкой
  static const int feedNow = 0x07;

  // Сброс
  static const int resetStatistics = 0x08;
}
