import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'project.dart';

class ProjectsStorage {
  static const _key = "ari_projects";

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final data = projects
        .map((p) => {
              "id": p.id,
              "title": p.title,
              "description": p.description,
              "completed": p.completed,
            })
        .toList();
    prefs.setString(_key, jsonEncode(data));
  }

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map((p) => Project(
              id: p["id"],
              title: p["title"],
              description: p["description"],
              completed: p["completed"],
            ))
        .toList();
  }
}
