import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/tasklist_provider.dart';
import 'package:go_router/go_router.dart';

class AddRoutine extends ConsumerWidget {
  String googleId;

  AddRoutine(
      {Key? key,
      required this.googleId,
      required TaskListNotifier taskListNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController taskNameController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    final taskListNotifier = ref.read(taskListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Routine',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: taskNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary)),
                labelText: 'Task name',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: durationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a duration';
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary)),
                labelText: 'Duration (minutes)',
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final taskName = taskNameController.text;
                  final duration = durationController.text;
                  if (taskName.isNotEmpty) {
                    final task = Task(name: taskName, duration: duration);
                    taskListNotifier.addTask(task);
                    context.go('/preference/$googleId');
                  } else {
                    // Show error message
                  }
                },
                child: const Text("Create"),
              ),
            ),
            // IconButton(
            //   onPressed: () {
            //     context.go('/setting');
            //   },
            //   icon: const Icon(Icons.settings),
            // ),
          ],
        ),
      ),
    );
  }
}
