import 'package:flutter/material.dart';

class RadarChartStyle {
  final Color backgroundColor;
  final Color gridColor;
  final Color labelColor;
  final Color valueLabelColor;
  final Color legendTextColor;
  final double gridStrokeWidth;
  final double seriesStrokeWidth;
  final int gridLevels;
  final TextStyle? labelStyle;
  final TextStyle? legendStyle;
  final EdgeInsetsGeometry padding;

  const RadarChartStyle({
    this.backgroundColor = Colors.transparent,
    this.gridColor = const Color(0xFFE0E4EA),
    this.labelColor = const Color(0xFF111827),
    this.valueLabelColor = const Color(0xFF6B7280),
    this.legendTextColor = const Color(0xFF111827),
    this.gridStrokeWidth = 1,
    this.seriesStrokeWidth = 2,
    this.gridLevels = 5,
    this.labelStyle,
    this.legendStyle,
    this.padding = const EdgeInsets.all(16),
  }) : assert(gridLevels > 0);
}
