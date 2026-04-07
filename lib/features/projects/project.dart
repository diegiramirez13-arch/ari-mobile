class Project {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
    );
  }
}
