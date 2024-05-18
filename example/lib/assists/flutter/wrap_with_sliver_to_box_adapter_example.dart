import 'package:flutter/material.dart';

class WrapWithSliverToBoxAdapterExample extends StatelessWidget {
  const WrapWithSliverToBoxAdapterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 100,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                color: Colors.green,
                height: 100,
              );
            },
            childCount: 10,
          ),
        ),
        const SliverToBoxAdapter(
          child: Text(''),
        ),
      ],
    );
  }
}
