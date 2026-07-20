import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compare_radar_chart/compare_radar_chart.dart';

void main() {
  testWidgets('renders compare radar chart without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CompareRadarChart(
              size: 260,
              axes: [
                RadarChartAxis(label: 'Goals', maxValue: 50),
                RadarChartAxis(label: 'Wins', maxValue: 20),
                RadarChartAxis(label: 'Points', maxValue: 150),
                RadarChartAxis(label: 'MOTM', maxValue: 10),
                RadarChartAxis(label: 'Fair Play', maxValue: 100),
              ],
              series: [
                RadarChartSeries(
                  name: 'Player A',
                  values: [42, 18, 120, 7, 92],
                  color: Colors.blue,
                ),
                RadarChartSeries(
                  name: 'Player B',
                  values: [35, 14, 105, 8, 88],
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Player A'), findsWidgets);
    expect(find.text('Player B'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows colored series value bars on hover', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CompareRadarChart(
              size: 260,
              showLegend: false,
              axes: [
                RadarChartAxis(label: 'Goals', maxValue: 50),
                RadarChartAxis(label: 'Wins', maxValue: 20),
                RadarChartAxis(label: 'Points', maxValue: 150),
              ],
              series: [
                RadarChartSeries(
                  name: 'Player A',
                  values: [42, 18, 120],
                  color: Colors.blue,
                ),
                RadarChartSeries(
                  name: 'Player B',
                  values: [35, 14, 105],
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(CompareRadarChart)));
    await tester.pump();

    expect(find.text('0 - 50'), findsOneWidget);
    expect(find.text('0 - 20'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Player A'), findsWidgets);
    expect(find.text('Player B'), findsWidgets);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps tooltip visible when mouse moves over panel', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CompareRadarChart(
              size: 260,
              showLegend: false,
              axes: [
                RadarChartAxis(label: 'Goals', maxValue: 50),
                RadarChartAxis(label: 'Wins', maxValue: 20),
                RadarChartAxis(label: 'Points', maxValue: 150),
              ],
              series: [
                RadarChartSeries(
                  name: 'Player A',
                  values: [42, 18, 120],
                  color: Colors.blue,
                ),
                RadarChartSeries(
                  name: 'Player B',
                  values: [35, 14, 105],
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(CompareRadarChart)));
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(SingleChildScrollView)));
    await tester.pump(const Duration(milliseconds: 140));

    expect(find.text('0 - 50'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows series value bars on tap for phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CompareRadarChart(
              size: 240,
              showLegend: false,
              axes: [
                RadarChartAxis(label: 'Goals', maxValue: 50),
                RadarChartAxis(label: 'Wins', maxValue: 20),
                RadarChartAxis(label: 'Points', maxValue: 150),
                RadarChartAxis(label: 'MOTM', maxValue: 10),
                RadarChartAxis(label: 'Fair Play', maxValue: 100),
              ],
              series: [
                RadarChartSeries(
                  name: 'Player A',
                  values: [42, 18, 120, 7, 92],
                  color: Colors.blue,
                ),
                RadarChartSeries(
                  name: 'Player B',
                  values: [35, 14, 105, 8, 88],
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CompareRadarChart));
    await tester.pump();

    expect(find.text('0 - 100'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
