import 'package:flutter/material.dart';

class backButton extends StatelessWidget {
  const backButton({super.key,required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios,  color: isDark ? Colors.white : Colors.black, size: 20),
      onPressed: () => Navigator.pop(context),
    );
  }
}
