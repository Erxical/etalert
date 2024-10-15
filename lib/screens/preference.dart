import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    var screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Self-prepared routines',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Wrap(
              children: [
                Text(
                  'Add your self-prepare routine in order from first to last',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  overflow: TextOverflow.fade,
                ),
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      context.push('/addroutine/$googleId');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: tasks.map((task) {
                      return Column(
                        children: [
                          Card(
                            elevation: 2.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.name,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Row(
                                          children: [
                                            Text(
                                              task.duration.toString(),
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                int.parse(task.duration) <= 1
                                                    ? 'min'
                                                    : 'mins',
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Icon(Icons.density_medium_rounded,
                                  //     color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 35, left: 16, right: 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () async {
            for (int i = 0; i < tasks.length; i++) {
              int dur = int.parse(tasks[i].duration);
              await createRoutine(googleId, tasks[i].name, dur, i + 1);
            }

            context.go('/$googleId');
          },
          child: const Text(
            'Finish',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
