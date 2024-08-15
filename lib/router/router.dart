// import 'package:frontend/providers/tasklist_provider.dart';
// import 'package:frontend/screens/addroutine.dart';
// import 'package:frontend/screens/calendar.dart';
// import 'package:frontend/screens/editinfo.dart';
// import 'package:frontend/screens/login.dart';
// import 'package:frontend/screens/name_setup.dart';
// import 'package:frontend/screens/bedtime.dart';
// import 'package:frontend/screens/preference.dart';
// import 'package:frontend/screens/setting.dart';
// import 'package:go_router/go_router.dart';

// final router = GoRouter(initialLocation: '/login', routes: [
//   GoRoute(
//     path: '/',
//     builder: (context, state) => const Calendar(),
//   ),
//   GoRoute(
//     path: '/login',
//     builder: (context, state) => const Login(),
//   ),
//   GoRoute(
//     path: '/name',
//     builder: (context, state) => const NameSetup(),
//   ),
//   GoRoute(
//     path: '/bedtime',
//     builder: (context, state) => const Bedtime(),
//   ),
//   GoRoute(
//     path: '/preference',
//     builder: (context, state) => const Preference(),
//   ),
//   GoRoute(
//     path: '/addroutine',
//     builder: (context, state) {
//       // Retrieve the taskListNotifier from the context
//       final taskListNotifier =
//           TaskListNotifier(); // Replace with your actual provider initialization
//       return AddRoutine(taskListNotifier: taskListNotifier);
//     },
//   ),
//   GoRoute(
//     path: '/setting',
//     builder: (context, state) => const Setting(),
//   ),
//   GoRoute(
//     path: '/editinfo',
//     builder: (context, state) => const Editinfo(),
//   )
// ]);
