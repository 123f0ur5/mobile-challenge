import 'package:flutter/material.dart';

class RouteUtils {
  static Route<void> fadeTransitionRoute(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<double>(begin: 0.0, end: 1.0);
        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
