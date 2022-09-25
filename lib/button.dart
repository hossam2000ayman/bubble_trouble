import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final icon;
  final function;

  const MyButton({required this.icon, this.function});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 50,
          height: 50,
          child: Center(
            child: Icon(icon),
          ),
          color: Colors.grey[100],
        ),
      ),
    );
  }
}
