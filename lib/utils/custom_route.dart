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
    // 将线性的动画（animation）转换为非线性的曲线动画（curvedAnimation）。
    final curvedAnimation = CurvedAnimation(
      parent: animation, // 原始的线性动画，其值在 0.0 到 1.0 之间均匀变化。
      curve: Curves.fastOutSlowIn, // 一种预设的动画曲线，效果是“快出慢入”，使动画更自然。
    );

    // 组合滑动和淡入两种过渡效果。
    return SlideTransition(
      // 使用 SlideTransition 组件实现平移动画。
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // 定义动画的起始位置（屏幕右侧外部）。
        end: Offset.zero, // 定义动画的结束位置（屏幕原点）。
      ).animate(curvedAnimation), // 将曲线动画应用到位置变化上。
      child: FadeTransition(
        opacity: curvedAnimation, // 同时，将曲线动画应用到透明度变化上，实现淡入效果。
        child: child, // child 就是将要显示的新页面。
      ),
    );
  }
}
