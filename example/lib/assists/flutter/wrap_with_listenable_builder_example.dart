import 'package:flutter/widgets.dart';

class WrapWithValueListenableBuilderExample extends StatefulWidget {
  const WrapWithValueListenableBuilderExample({super.key});

  @override
  State<WrapWithValueListenableBuilderExample> createState() =>
      _WrapWithValueListenableBuilderExampleState();
}

class _WrapWithValueListenableBuilderExampleState
    extends State<WrapWithValueListenableBuilderExample> {
  late final _nameController = ValueNotifier<String>('Pyramid');
  late final _ageController = ValueNotifier(12);

  @override
  void dispose() {
    _ageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Name: ${_nameController.value} and Age: ${_ageController.value}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
