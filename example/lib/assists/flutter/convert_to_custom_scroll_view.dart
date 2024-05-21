import 'package:flutter/widgets.dart';

class ConvertToCustomScrollView extends StatelessWidget {
  const ConvertToCustomScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('Hello World'),
        Column(),
        Row(),
      ],
    );
  }
}
