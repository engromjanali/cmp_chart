class RadarChartAxis {
  final String label;
  final double maxValue;

  const RadarChartAxis({
    required this.label,
    this.maxValue = 100,
  }) : assert(maxValue > 0);
}
