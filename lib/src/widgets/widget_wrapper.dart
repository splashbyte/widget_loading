import 'package:flutter/material.dart';

class WidgetSizedBox extends StatelessWidget {
  final Widget child;

  const WidgetSizedBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      child: child,
      opacity: 0.0,
    );
  }
}

class WidgetWrapper extends StatelessWidget {
  final Widget child;
  const WidgetWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

