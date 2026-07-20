import 'package:flutter_test/flutter_test.dart';

import 'package:compare_radar_chart_example/main.dart';

void main() {
  testWidgets('example renders compare radar chart', (tester) async {
    await tester.pumpWidget(const CompareRadarChartExampleApp());

    expect(find.text('Compare Radar Chart'), findsOneWidget);
    expect(find.text('Player A'), findsOneWidget);
    expect(find.text('Player B'), findsOneWidget);
  });
}
