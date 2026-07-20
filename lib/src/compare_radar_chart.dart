import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:compare_radar_chart/src/radar_chart_axis.dart';
import 'package:compare_radar_chart/src/radar_chart_series.dart';
import 'package:compare_radar_chart/src/radar_chart_style.dart';

class CompareRadarChart extends StatelessWidget {
  final List<RadarChartAxis> axes;
  final List<RadarChartSeries> series;
  final RadarChartStyle style;
  final double size;
  final bool showLegend;
  final bool showValues;

  const CompareRadarChart({
    super.key,
    required this.axes,
    required this.series,
    this.style = const RadarChartStyle(),
    this.size = 320,
    this.showLegend = true,
    this.showValues = false,
  });

  @override
  Widget build(BuildContext context) {
    _validateSeries();

    final chart = _RadarChartTooltip(
      axes: axes,
      series: series,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CompareRadarChartPainter(
            axes: axes,
            series: series,
            style: style,
            showValues: showValues,
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: style.backgroundColor),
      child: Padding(
        padding: style.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: chart,
            ),
            if (showLegend && series.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: series.map(_buildLegendItem).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(RadarChartSeries item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.legendStyle ?? TextStyle(
            color: style.legendTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _validateSeries() {
    assert(axes.length >= 3);
    for (final item in series) {
      assert(item.values.length == axes.length);
    }
  }
}

class _RadarChartTooltip extends StatefulWidget {
  final List<RadarChartAxis> axes;
  final List<RadarChartSeries> series;
  final Widget child;

  const _RadarChartTooltip({
    required this.axes,
    required this.series,
    required this.child,
  });

  @override
  State<_RadarChartTooltip> createState() => _RadarChartTooltipState();
}

class _RadarChartTooltipState extends State<_RadarChartTooltip> {
  OverlayEntry? _entry;
  Timer? _timer;
  Timer? _hideTimer;

  @override
  void dispose() {
    _timer?.cancel();
    _hideTimer?.cancel();
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showTooltip(),
      onExit: (_) => _scheduleHideTooltip(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showTemporaryTooltip,
        onLongPress: _showTemporaryTooltip,
        child: widget.child,
      ),
    );
  }

  void _showTemporaryTooltip() {
    _showTooltip();
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _hideTooltip();
      }
    });
  }

  void _showTooltip() {
    _hideTimer?.cancel();

    if (_entry != null || widget.series.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;

    if (renderBox == null || overlayBox == null) {
      return;
    }

    final targetOffset = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final targetSize = renderBox.size;
    final overlaySize = overlayBox.size;
    final panelWidth = math.min(340.0, math.max(240.0, overlaySize.width - 24));
    final panelHeight = math.min(360.0, math.max(220.0, overlaySize.height * 0.45));
    final left = (targetOffset.dx + targetSize.width / 2 - panelWidth / 2).clamp(12.0, overlaySize.width - panelWidth - 12);
    var top = targetOffset.dy + targetSize.height + 8;

    if (top + panelHeight > overlaySize.height - 12) {
      top = targetOffset.dy - panelHeight - 8;
    }

    top = top.clamp(12.0, overlaySize.height - panelHeight - 12);

    _entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: left,
          top: top,
          width: panelWidth,
          child: MouseRegion(
            onEnter: (_) => _hideTimer?.cancel(),
            onExit: (_) => _scheduleHideTooltip(),
            child: _RadarChartTooltipPanel(
              axes: widget.axes,
              series: widget.series,
              maxHeight: panelHeight,
            ),
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  void _scheduleHideTooltip() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 120), _hideTooltip);
  }

  void _hideTooltip() {
    _hideTimer?.cancel();
    _entry?.remove();
    _entry = null;
  }
}

class _RadarChartTooltipPanel extends StatelessWidget {
  final List<RadarChartAxis> axes;
  final List<RadarChartSeries> series;
  final double maxHeight;

  const _RadarChartTooltipPanel({
    required this.axes,
    required this.series,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var axisIndex = 0; axisIndex < axes.length; axisIndex++) ...[
                  _RadarChartTooltipAxis(
                    axis: axes[axisIndex],
                    series: series,
                    axisIndex: axisIndex,
                  ),
                  if (axisIndex != axes.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarChartTooltipAxis extends StatelessWidget {
  final RadarChartAxis axis;
  final List<RadarChartSeries> series;
  final int axisIndex;

  const _RadarChartTooltipAxis({
    required this.axis,
    required this.series,
    required this.axisIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                axis.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '0 - ${_formatValue(axis.maxValue)}',
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in series) ...[
          _RadarChartTooltipSeriesBar(
            item: item,
            value: item.values[axisIndex].clamp(0, axis.maxValue).toDouble(),
            maxValue: axis.maxValue,
          ),
          if (item != series.last) const SizedBox(height: 7),
        ],
      ],
    );
  }
}

class _RadarChartTooltipSeriesBar extends StatelessWidget {
  final RadarChartSeries item;
  final double value;
  final double maxValue;

  const _RadarChartTooltipSeriesBar({
    required this.item,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percent = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: item.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF374151)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percent,
                    child: ColoredBox(color: item.color),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            _formatValue(value),
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatValue(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

class _CompareRadarChartPainter extends CustomPainter {
  final List<RadarChartAxis> axes;
  final List<RadarChartSeries> series;
  final RadarChartStyle style;
  final bool showValues;

  const _CompareRadarChartPainter({
    required this.axes,
    required this.series,
    required this.style,
    required this.showValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final labelSpace = showValues ? 56.0 : 42.0;
    final radius = math.max(0.0, math.min(size.width, size.height) / 2 - labelSpace);
    final gridPaint = Paint()
      ..color = style.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.gridStrokeWidth;
    final axisPaint = Paint()
      ..color = style.gridColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.gridStrokeWidth;

    for (var level = 1; level <= style.gridLevels; level++) {
      final levelRadius = radius * level / style.gridLevels;
      canvas.drawPath(_polygonPath(center, levelRadius), gridPaint);
    }

    for (var index = 0; index < axes.length; index++) {
      final point = _pointFor(center, radius, index, 1);
      canvas.drawLine(center, point, axisPaint);
      _drawAxisLabel(canvas, size, center, radius, index);
    }

    for (final item in series) {
      _drawSeries(canvas, center, radius, item);
    }
  }

  Path _polygonPath(Offset center, double radius) {
    final path = Path();

    for (var index = 0; index < axes.length; index++) {
      final point = _pointFor(center, radius, index, 1);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  Offset _pointFor(Offset center, double radius, int index, double percent) {
    final angle = -math.pi / 2 + (math.pi * 2 * index / axes.length);
    return Offset(
      center.dx + math.cos(angle) * radius * percent,
      center.dy + math.sin(angle) * radius * percent,
    );
  }

  void _drawSeries(Canvas canvas, Offset center, double radius, RadarChartSeries item) {
    final fillPaint = Paint()
      ..color = item.color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = item.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.seriesStrokeWidth;
    final pointPaint = Paint()
      ..color = item.color
      ..style = PaintingStyle.fill;
    final path = Path();

    for (var index = 0; index < axes.length; index++) {
      final value = item.values[index].clamp(0, axes[index].maxValue).toDouble();
      final percent = value / axes[index].maxValue;
      final point = _pointFor(center, radius, index, percent);

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawCircle(point, 3, pointPaint);

      if (showValues) {
        _drawValueLabel(canvas, point, value);
      }
    }

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawAxisLabel(Canvas canvas, Size size, Offset center, double radius, int index) {
    final axis = axes[index];
    final point = _pointFor(center, radius + 24, index, 1);
    final textPainter = TextPainter(
      text: TextSpan(
        text: axis.label,
        style: style.labelStyle ?? TextStyle(
          color: style.labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      ellipsis: '',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 84);
    final safeDx = (point.dx - textPainter.width / 2).clamp(0.0, size.width - textPainter.width);
    final safeDy = (point.dy - textPainter.height / 2).clamp(0.0, size.height - textPainter.height);

    textPainter.paint(canvas, Offset(safeDx, safeDy));
  }

  void _drawValueLabel(Canvas canvas, Offset point, double value) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
        style: TextStyle(
          color: style.valueLabelColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 40);

    textPainter.paint(canvas, Offset(point.dx - textPainter.width / 2, point.dy - textPainter.height - 4));
  }

  @override
  bool shouldRepaint(_CompareRadarChartPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.series != series ||
        oldDelegate.style != style ||
        oldDelegate.showValues != showValues;
  }
}
