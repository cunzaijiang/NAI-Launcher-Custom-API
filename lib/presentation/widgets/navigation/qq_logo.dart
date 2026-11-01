import 'package:flutter/material.dart';

/// Standard QQ brand icon from Simple Icons (CC0-1.0).
/// Source: https://github.com/simple-icons/simple-icons/blob/
/// 90646e4bf7f3b89df6c37e65baf3e7bc759a517c/icons/qq.svg
class QQLogo extends StatelessWidget {
  const QQLogo({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) => ImageIcon(
    const AssetImage('assets/icons/qq.png'),
    color: color,
    size: size,
  );
}
