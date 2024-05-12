import 'package:flutter/widgets.dart';

class DisposeControllerWidget extends StatefulWidget {
  const DisposeControllerWidget({super.key});

  @override
  State<DisposeControllerWidget> createState() =>
      DisposeControllerWidgetState();
}

class DisposeControllerWidgetState extends State<DisposeControllerWidget> {
  // ignore: avoid_multiple_declarations_per_line
  late final _nameController = ValueNotifier(null),
      _ageController = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
