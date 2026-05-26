
import 'package:flutter/material.dart';
class PinCodeField extends StatelessWidget {
  final int length; final ValueChanged<String> onChanged;
  const PinCodeField({super.key, this.length = 4, required this.onChanged});
  @override Widget build(BuildContext context) => Row(children: List.generate(length, (i) => Expanded(child: TextField(onChanged: onChanged))));
}
