enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromApi(String value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        throw ArgumentError('Unknown priority: $value');
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed;

  static TaskStatus fromApi(String value) {
    switch (value) {
      case 'pending':
        return TaskStatus.pending;
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        throw ArgumentError('Unknown status: $value');
    }
  }
}
