import 'package:flutter/material.dart';

class SlideRightRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  SlideRightRoute({required this.builder})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => builder(context),
        transitionsBuilder: _buildTransitions,
        transitionDuration: const Duration(milliseconds: 300),
      );

  static Widget _buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use a standard Material Design curve.
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
    );

    // Combine Fade and Slide transitions.
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  }
}
