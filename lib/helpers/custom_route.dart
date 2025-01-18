import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
  }) : super(
          builder: builder,
        );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
