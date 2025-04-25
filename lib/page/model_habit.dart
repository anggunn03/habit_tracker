class Habit {
  final String id;
  final String name;
  final String? description;

  Habit({required this.id, required this.name, this.description});

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
    };
  }
}