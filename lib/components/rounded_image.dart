import 'package:flutter/material.dart';

class RoundedImage extends StatelessWidget {
  final String url;
  const RoundedImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.fromSize(
        size: const Size.fromRadius(70.5), // Image radius
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
