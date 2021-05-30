import 'package:flutter/material.dart';

Widget mySnackBar(IconData icon, String mensaje, Color color) {
  return SnackBar(
    backgroundColor: color,
    content: Container(
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 20),
          Expanded(child: Text(mensaje))
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 1800),
  );
}
