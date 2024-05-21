import 'package:flutter/widgets.dart';

class ConvertToTextRich extends StatelessWidget {
  const ConvertToTextRich({super.key});

  @override
  Widget build(BuildContext context) {
    String fc() {
      return '';
    }

    return Column(
      children: [
        Text(
          key: const ValueKey(''),
          fc(),
        ),
        const Text.rich(
          TextSpan(
            children: [],
          ),
        ),
      ],
    );
  }
}
