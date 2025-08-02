import 'package:flutter/material.dart';

class AdditionalInfoCards extends StatelessWidget {
  final IconData icon;
  final String text;
  final String value;
  const AdditionalInfoCards({
    super.key,
    required this.icon,
    required this.text,
    required this.value
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 32),
        SizedBox(height: 12),
        Text(text, style: TextStyle(fontSize: 18)),
        SizedBox(height: 11),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
