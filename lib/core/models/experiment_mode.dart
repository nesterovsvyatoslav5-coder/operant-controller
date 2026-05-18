enum ExperimentMode {
  training,
  experiment,
}

extension ExperimentModeX on ExperimentMode {
  int get code {
    switch (this) {
      case ExperimentMode.training:
        return 0x00;
      case ExperimentMode.experiment:
        return 0x01;
    }
  }

  String get title {
    switch (this) {
      case ExperimentMode.training:
        return 'Обучение';
      case ExperimentMode.experiment:
        return 'Эксперимент';
    }
  }
}
