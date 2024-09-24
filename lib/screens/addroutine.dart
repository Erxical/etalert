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
        centerTitle: false,
        title: Text(
          'Add Routine',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        final taskName = taskNameController.text;
                        final duration = durationController.text;
                        if (taskName.isNotEmpty) {
                          final task = Task(name: taskName, duration: duration);
                          taskListNotifier.addTask(task);
                          context.pop();
                        } else {
                          // Show error message
                        }
                      },
                      child: const Text("Create"),
                    ),
                  ),
                ],
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
