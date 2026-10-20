import 'package:flutter/material.dart';

/// Distributes a list of widgets across N balanced columns for Tablet Landscape.
/// Allows items to retain natural heights, preventing text or card clipping.
class CourseTabletGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int columnCount;

  const CourseTabletGrid({
    super.key,
    required this.children,
    this.spacing = 18.0,
    this.columnCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final columns = List.generate(columnCount, (_) => <Widget>[]);

    for (int i = 0; i < children.length; i++) {
      columns[i % columnCount].add(children[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < columnCount; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: columns[i],
            ),
          ),
        ],
      ],
    );
  }
}
