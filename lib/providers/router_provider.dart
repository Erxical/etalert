import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/tasklist_provider.dart';
import 'package:frontend/screens/addroutine.dart';
import 'package:frontend/screens/calendar.dart';
import 'package:frontend/screens/editinfo.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/bedtime.dart';
import 'package:frontend/screens/name_setup.dart';
import 'package:frontend/screens/preference.dart';
import 'package:frontend/screens/setting.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/login', routes: [
    GoRoute(path: '/', builder: (context, state) => Calendar()),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
        path: '/name/:googleId',
        builder: (context, state) {
          final googleId = state.params['googleId']!;
          if (googleId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid googleId')),
            );
          }
          return NameSetup(
            googleId: googleId,
          );
        }),
    GoRoute(
      path: '/bedtime/:googleId',
      builder: (context, state) {
        final googleId = state.params['googleId']!;
        if (googleId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid googleId')),
          );
        }
        return Bedtime(
          googleId: googleId,
        );
      },
    ),
    GoRoute(
      path: '/preference/:googleId',
      builder: (context, state) {
        final googleId = state.params['googleId']!;
        if (googleId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid googleId')),
          );
        }
        return Preference(
          googleId: googleId,
        );
      },
    ),
    GoRoute(
      path: '/addroutine/:googleId',
      builder: (context, state) {
        final googleId = state.params['googleId']!;
        final taskListNotifier = TaskListNotifier();
        if (googleId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid googleId')),
          );
        }
        return AddRoutine(
            googleId: googleId, taskListNotifier: taskListNotifier);
      },
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => const Setting(),
    ),
    GoRoute(
      path: '/editinfo',
      builder: (context, state) => const Editinfo(),
    )
  ]);
});
