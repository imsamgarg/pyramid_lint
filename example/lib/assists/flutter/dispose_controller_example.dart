// ignore_for_file: proper_controller_dispose, unused_field
import 'package:flutter/widgets.dart';

class DisposeControllerWidget extends StatefulWidget {
  const DisposeControllerWidget({super.key});

  @override
  State<DisposeControllerWidget> createState() =>
      DisposeControllerWidgetState();
}

class DisposeControllerWidgetState extends State<DisposeControllerWidget> {
  late final _nameController = ValueNotifier(null);
  late final _ageController = ValueNotifier(null);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
