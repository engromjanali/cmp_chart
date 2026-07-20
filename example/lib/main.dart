import 'package:flutter/material.dart';
import 'package:compare_radar_chart/compare_radar_chart.dart';

void main() {
  runApp(const CompareRadarChartExampleApp());
}

class CompareRadarChartExampleApp extends StatelessWidget {
  const CompareRadarChartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const CompareRadarChartExampleScreen(),
    );
  }
}

class CompareRadarChartExampleScreen extends StatelessWidget {
  const CompareRadarChartExampleScreen({super.key});

  static const axes = [
    RadarChartAxis(label: 'Goals', maxValue: 50),
    RadarChartAxis(label: 'Wins', maxValue: 20),
    RadarChartAxis(label: 'Points', maxValue: 150),
    RadarChartAxis(label: 'MOTM', maxValue: 10),
    RadarChartAxis(label: 'Clean', maxValue: 10),
    RadarChartAxis(label: 'Fair', maxValue: 100),
  ];

  static const series = [
    RadarChartSeries(
      name: 'Player A',
      values: [42, 18, 120, 7, 5, 92],
      color: Color(0xFF2563EB),
    ),
    RadarChartSeries(
      name: 'Player B',
      values: [35, 14, 105, 8, 7, 88],
      color: Color(0xFFF97316),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Compare Radar Chart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const CompareRadarChart(
                size: 320,
                axes: axes,
                series: series,
                showValues: true,
                style: RadarChartStyle(
                  backgroundColor: Colors.white,
                  gridColor: Color(0xFFCBD5E1),
                  labelColor: Color(0xFF0F172A),
                  valueLabelColor: Color(0xFF475569),
                  legendTextColor: Color(0xFF0F172A),
                  gridLevels: 5,
                  padding: EdgeInsets.all(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
