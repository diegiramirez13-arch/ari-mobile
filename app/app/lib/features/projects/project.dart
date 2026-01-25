class Project {
  final String id;
  final String title;
  final String description;
  final bool completed;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });
}
