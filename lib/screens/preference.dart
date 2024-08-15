import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/theme/custom_color.g.dart';
import 'package:frontend/providers/tasklist_provider.dart';
import 'package:frontend/services/data/routine/create_routine.dart';
import 'package:go_router/go_router.dart';

class Preference extends ConsumerWidget {
  String googleId;

  Preference({Key? key, required this.googleId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'What are your self-prepare routines?',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.go('/addroutine/$googleId');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Column(
              children: tasks.map((task) {
                return Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: const TextStyle(
                                    color: pinkColor, fontSize: 16.0),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                task.duration as String,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.density_medium_rounded,
                            color: Colors.grey[600]),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: () async {
                  final future = await tasks.map((tasks) async {
                    int dur = int.parse(tasks.duration);
                    await createRoutine(googleId, tasks.name, dur);
                  });

                  await Future.wait(future);

                  context.go('/');
                },
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
