import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final String name;
  final String duration;

  Task({required this.name, required this.duration});
}

class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier();
});
