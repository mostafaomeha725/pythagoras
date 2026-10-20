import 'package:flutter/material.dart';

/// Distributes a list of task cards into two balanced columns for Tablet Landscape.
/// Avoids fixed aspect ratios, preventing text clipping and RenderFlex overflows.
class CourseTasksTwoColumnGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const CourseTasksTwoColumnGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final rightCol = <Widget>[];
    final leftCol = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      if (i.isEven) {
        rightCol.add(children[i]);
      } else {
        leftCol.add(children[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rightCol,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: leftCol,
          ),
        ),
      ],
    );
  }
}
