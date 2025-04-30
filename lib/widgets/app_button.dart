import 'package:flutter/material.dart';

class AppBtn extends StatelessWidget {
  const AppBtn({super.key, required this.text, required this.onpressed});

  final String text;
  final void Function()? onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onpressed,
        child: Text(text),
      ),
    );
  }
}
