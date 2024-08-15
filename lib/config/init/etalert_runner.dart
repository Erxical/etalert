import 'package:dynamic_color/dynamic_color.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/theme/color_schemes.g.dart';
import 'package:frontend/providers/router_provider.dart';
import '../theme/custom_color.g.dart';

class ETAlert extends ConsumerWidget {
  const ETAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          lightCustomColors = lightCustomColors.harmonized(lightScheme);

          // Repeat for the dark color scheme.
          darkScheme = darkDynamic.harmonized();
          darkCustomColors = darkCustomColors.harmonized(darkScheme);
        } else {
          // Otherwise, use fallback schemes.
          lightScheme = lightColorScheme;
          darkScheme = darkColorScheme;
        }

        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'ETAlert',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            extensions: [lightCustomColors],
          ),
          // darkTheme: ThemeData(
          //   useMaterial3: true,
          //   colorScheme: darkScheme,
          //   extensions: [darkCustomColors],
          // ),
          routerConfig: router,
        );
      },
    );
  }
}
