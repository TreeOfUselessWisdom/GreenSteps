import 'package:flutter/material.dart';
import '../core/responsive_layout.dart';

class ResponsiveGridWidget extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGridWidget({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.runSpacing = 12.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.getGridColumns(context);
    final rows = (children.length / columns).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = (width - (columns - 1) * spacing) / columns;
        final itemHeight = itemWidth / childAspectRatio;

        final gridHeight = itemHeight * rows + runSpacing * (rows - 1);

        return SizedBox(
          height: gridHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          ),
        );
      },
    );
  }
}

