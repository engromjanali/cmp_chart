# compare_radar_chart

A customizable Flutter radar chart widget for comparing multiple data series across shared metrics.

## Features

- Compare two or more series on the same radar chart.
- Per-axis maximum values for safe normalization.
- Configurable colors, grid levels, labels, legend, padding, and chart size.
- Values are clamped to each axis max to avoid drawing outside the chart.
- No network, storage, or analytics dependency.

## Getting started

Add the package:

```yaml
dependencies:
  compare_radar_chart: ^0.0.1
```

Import it:

```dart
import 'package:compare_radar_chart/compare_radar_chart.dart';
```

## Usage

```dart
CompareRadarChart(
  axes: const [
    RadarChartAxis(label: 'Goals', maxValue: 50),
    RadarChartAxis(label: 'Wins', maxValue: 20),
    RadarChartAxis(label: 'Points', maxValue: 150),
    RadarChartAxis(label: 'MOTM', maxValue: 10),
    RadarChartAxis(label: 'Fair Play', maxValue: 100),
  ],
  series: const [
    RadarChartSeries(
      name: 'Player A',
      values: [42, 18, 120, 7, 92],
      color: Color(0xFF2563EB),
    ),
    RadarChartSeries(
      name: 'Player B',
      values: [35, 14, 105, 8, 88],
      color: Color(0xFFF97316),
    ),
  ],
)
```

See the `/example` app for a complete screen.

## Custom style

```dart
CompareRadarChart(
  axes: axes,
  series: series,
  showValues: true,
  style: const RadarChartStyle(
    gridColor: Color(0xFFCBD5E1),
    labelColor: Color(0xFF0F172A),
    gridLevels: 4,
  ),
)
```

## Data safety

The widget only renders the data passed to it. It does not send analytics, make network requests, read files, or store chart data.
