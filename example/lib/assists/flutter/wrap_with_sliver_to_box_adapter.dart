import 'package:flutter/widgets.dart';

class WrapWithSliverToBoxAdapterExample extends StatelessWidget {
  const WrapWithSliverToBoxAdapterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        Container(),
      ],
    );
  }
}
