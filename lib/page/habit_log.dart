class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool status;

  HabitLog({required this.id, required this.habitId, required this.date, required this.status});

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.parse(map['date']),
      status: map['status'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
