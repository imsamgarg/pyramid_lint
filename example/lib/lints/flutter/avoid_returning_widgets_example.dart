// ignore_for_file: avoid_widget_state_public_members

import 'package:flutter/material.dart';

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  // expect_lint: avoid_returning_widgets
  Widget _buildWidget() {
    return const Placeholder();
  }
}

class B extends StatefulWidget {
  const B({super.key});

  @override
  State<B> createState() => _BState();
}

class _BState extends State<B> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        myWidget,
        _buildWidget(),
      ],
    );
  }

  // expect_lint: avoid_returning_widgets
  Widget get myWidget => const Placeholder();

  // expect_lint: avoid_returning_widgets
  Widget _buildWidget() => const Placeholder();
}

// expect_lint: avoid_returning_widgets
Widget buildWidget() => const Placeholder();

// expect_lint: avoid_returning_widgets
Widget get myWidget => const Placeholder();

class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget({
    super.key,
    required super.child,
  });

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) => false;

  // Static methods are ignored.
  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}

Widget myMethod() {
  return const Placeholder();
}
