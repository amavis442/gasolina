// ABOUTME: Animated splash screen with car silhouette, fuel gauge, and price chart
// ABOUTME: Shown on app launch for 3 seconds before navigating to the main screen

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _gaugeController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _footerSlideAnimation;
  late Animation<double> _gaugeAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _footerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    );

    _chartAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    _entranceController.forward().then((_) => _gaugeController.forward());

    Future.delayed(const Duration(milliseconds: 3200), _navigateToMain);
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0F1E),
              Color(0xFF131B35),
              Color(0xFF0A0F1E),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_gaugeAnimation, _chartAnimation]),
                    builder: (context, _) {
                      return CustomPaint(
                        painter: SplashGraphicPainter(
                          gaugeProgress: _gaugeAnimation.value,
                          chartProgress: _chartAnimation.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
                SlideTransition(
                  position: _footerSlideAnimation,
                  child: _buildFooter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _titleSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF64B5F6), Colors.white, Color(0xFF90CAF9)],
              ).createShader(bounds),
              child: const Text(
                'GASOLINA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Brandstof bijhouden, slimmer rijden',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _footerTag(Icons.local_gas_station_outlined, 'Brandstof'),
          _footerDot(),
          _footerTag(Icons.speed_outlined, 'Verbruik'),
          _footerDot(),
          _footerTag(Icons.euro_outlined, 'Kosten'),
        ],
      ),
    );
  }

  Widget _footerTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFF9800), size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _footerDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '·',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 18,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter: draws car, gauge, and chart onto the available canvas area
// ---------------------------------------------------------------------------

class SplashGraphicPainter extends CustomPainter {
  final double gaugeProgress;
  final double chartProgress;

  const SplashGraphicPainter({
    required this.gaugeProgress,
    required this.chartProgress,
  });

  static const _fuelLevel = 0.68; // 68% full — used by gauge
  static const _priceData = [
    0.58, 0.62, 0.54, 0.70, 0.64, 0.78, 0.66, 0.72, 0.68, 0.75
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawCar(canvas, size);
    _drawGauge(canvas, size);
    _drawChart(canvas, size);
  }

  // ── Car silhouette ────────────────────────────────────────────────────────

  void _drawCar(Canvas canvas, Size size) {
    final cw = size.width * 0.82;
    final cl = (size.width - cw) / 2;
    final ct = size.height * 0.08;

    // Glow behind the car
    final glowPaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, ct + cw * 0.19),
        width: cw * 0.9,
        height: cw * 0.22,
      ),
      glowPaint,
    );

    final bodyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    // Main body path — modern sedan silhouette
    final body = Path();
    final bBottom = ct + cw * 0.275; // chassis rail bottom
    final bTop = ct + cw * 0.13; // shoulder line
    final roofY = ct + cw * 0.005; // roof peak

    // Start at front lower corner
    body.moveTo(cl + cw * 0.06, bBottom);

    // Front bumper (rounded lower front)
    body.quadraticBezierTo(
        cl + cw * 0.02, bBottom, cl + cw * 0.02, bBottom - cw * 0.04);
    body.lineTo(cl + cw * 0.02, bTop);

    // Hood slopes up toward windshield
    body.quadraticBezierTo(
        cl + cw * 0.04, bTop - cw * 0.005, cl + cw * 0.08, bTop - cw * 0.01);
    body.lineTo(cl + cw * 0.26, bTop - cw * 0.01);

    // Windshield
    body.lineTo(cl + cw * 0.335, roofY + cw * 0.005);

    // Roof arc
    body.quadraticBezierTo(cl + cw * 0.5, roofY - cw * 0.005,
        cl + cw * 0.66, roofY + cw * 0.005);

    // Rear window
    body.lineTo(cl + cw * 0.74, bTop - cw * 0.01);

    // Trunk / boot
    body.lineTo(cl + cw * 0.94, bTop - cw * 0.01);

    // Rear end (rounded)
    body.quadraticBezierTo(
        cl + cw * 0.98, bTop - cw * 0.01, cl + cw * 0.98, bTop + cw * 0.01);
    body.lineTo(cl + cw * 0.98, bBottom - cw * 0.04);
    body.quadraticBezierTo(
        cl + cw * 0.98, bBottom, cl + cw * 0.94, bBottom);

    // Bottom chassis line (skipping wheel arch gaps)
    body.lineTo(cl + cw * 0.82, bBottom);
    // Rear wheel arch
    body.arcTo(
        Rect.fromCenter(
            center: Offset(cl + cw * 0.74, bBottom), width: cw * 0.16, height: cw * 0.1),
        0,
        math.pi,
        false);
    body.lineTo(cl + cw * 0.28, bBottom);
    // Front wheel arch
    body.arcTo(
        Rect.fromCenter(
            center: Offset(cl + cw * 0.20, bBottom), width: cw * 0.16, height: cw * 0.1),
        0,
        math.pi,
        false);
    body.lineTo(cl + cw * 0.06, bBottom);
    body.close();

    canvas.drawPath(body, bodyPaint);

    // Windows (blue-tinted glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    // Windshield
    final windshield = Path()
      ..moveTo(cl + cw * 0.265, bTop - cw * 0.008)
      ..lineTo(cl + cw * 0.338, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.44, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.38, bTop - cw * 0.008)
      ..close();
    canvas.drawPath(windshield, glassPaint);

    // Middle window
    final midWindow = Path()
      ..moveTo(cl + cw * 0.40, bTop - cw * 0.008)
      ..lineTo(cl + cw * 0.46, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.56, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.56, bTop - cw * 0.008)
      ..close();
    canvas.drawPath(midWindow, glassPaint);

    // Rear window
    final rearWindow = Path()
      ..moveTo(cl + cw * 0.575, bTop - cw * 0.008)
      ..lineTo(cl + cw * 0.575, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.655, roofY + cw * 0.01)
      ..lineTo(cl + cw * 0.725, bTop - cw * 0.008)
      ..close();
    canvas.drawPath(rearWindow, glassPaint);

    // Headlight
    _drawLight(canvas, Offset(cl + cw * 0.028, bTop + cw * 0.02),
        cw * 0.022, const Color(0xFFFFF9C4));

    // Taillight
    _drawLight(canvas, Offset(cl + cw * 0.972, bTop + cw * 0.02),
        cw * 0.018, const Color(0xFFEF5350));

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF1A1F35)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = cw * 0.008
      ..style = PaintingStyle.stroke;

    _drawWheel(canvas, Offset(cl + cw * 0.20, bBottom + cw * 0.048),
        cw * 0.072, wheelPaint, rimPaint, spokePaint);
    _drawWheel(canvas, Offset(cl + cw * 0.74, bBottom + cw * 0.048),
        cw * 0.072, wheelPaint, rimPaint, spokePaint);

    // Ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, bBottom + cw * 0.115),
        width: cw * 0.82,
        height: cw * 0.03,
      ),
      shadowPaint,
    );
  }

  void _drawLight(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
        center,
        radius * 1.8,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, Paint wheel,
      Paint rim, Paint spoke) {
    canvas.drawCircle(center, radius, wheel);
    canvas.drawCircle(center, radius * 0.42, rim);
    // Spokes
    for (int i = 0; i < 5; i++) {
      final angle = (math.pi * 2 / 5) * i;
      canvas.drawLine(
        center,
        Offset(center.dx + math.cos(angle) * radius * 0.78,
            center.dy + math.sin(angle) * radius * 0.78),
        spoke,
      );
    }
  }

  // ── Fuel gauge ────────────────────────────────────────────────────────────

  void _drawGauge(Canvas canvas, Size size) {
    final cx = size.width * 0.25;
    final cy = size.height * 0.80;
    final r = size.width * 0.14;

    // Panel background
    final panelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2.8, height: r * 2.0),
      const Radius.circular(14),
    );
    canvas.drawRRect(
        panelRect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill);
    canvas.drawRRect(
        panelRect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);

    const startAngle = math.pi * 0.75; // 135°
    const sweepAngle = math.pi * 1.5; // 270° total sweep
    final arcRect =
        Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Arc track (background)
    canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..strokeWidth = r * 0.22
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Colored fill arc animated with gaugeProgress
    final currentLevel = _fuelLevel * gaugeProgress;
    if (currentLevel > 0) {
      // Gradient from green → orange by drawing segments
      const segments = 24;
      for (int i = 0; i < segments; i++) {
        final ratio = i / segments;
        if (ratio >= currentLevel) break;
        final segStart = startAngle + sweepAngle * ratio;
        final segEnd = startAngle + sweepAngle * ((i + 1) / segments);

        // Color: green → amber → orange
        final t = ratio / _fuelLevel;
        final Color segColor;
        if (t < 0.5) {
          segColor = Color.lerp(
              const Color(0xFF4CAF50), const Color(0xFFFFC107), t * 2)!;
        } else {
          segColor = Color.lerp(
              const Color(0xFFFFC107), const Color(0xFFFF9800), (t - 0.5) * 2)!;
        }

        canvas.drawArc(
            arcRect,
            segStart,
            segEnd - segStart + 0.01,
            false,
            Paint()
              ..color = segColor
              ..strokeWidth = r * 0.22
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.butt);
      }
    }

    // Needle
    final needleAngle = startAngle + sweepAngle * currentLevel;
    final needleEnd = Offset(
      cx + (r * 0.72) * math.cos(needleAngle),
      cy + (r * 0.72) * math.sin(needleAngle),
    );
    canvas.drawLine(
        Offset(cx, cy),
        needleEnd,
        Paint()
          ..color = Colors.white
          ..strokeWidth = r * 0.055
          ..strokeCap = StrokeCap.round);

    // Center pivot
    canvas.drawCircle(Offset(cx, cy), r * 0.1, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(cx, cy),
        r * 0.065,
        Paint()
          ..color = const Color(0xFF0A0F1E)
          ..style = PaintingStyle.fill);

    // E / F labels
    _drawGaugeLabel(canvas, 'E', cx, cy, r, startAngle - 0.18,
        Colors.white.withValues(alpha: 0.5));
    _drawGaugeLabel(canvas, 'F', cx, cy, r, startAngle + sweepAngle + 0.18,
        Colors.white.withValues(alpha: 0.5));

    // "FUEL" label
    final tp = TextPainter(
      text: TextSpan(
        text: 'FUEL',
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: r * 0.32,
            letterSpacing: 2,
            fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + r * 0.28));
  }

  void _drawGaugeLabel(Canvas canvas, String text, double cx, double cy,
      double r, double angle, Color color) {
    final labelR = r * 1.22;
    final pos = Offset(cx + labelR * math.cos(angle),
        cy + labelR * math.sin(angle));
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: r * 0.28, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  // ── Price chart ───────────────────────────────────────────────────────────

  void _drawChart(Canvas canvas, Size size) {
    final chartW = size.width * 0.44;
    final chartH = size.height * 0.30;
    final chartL = size.width * 0.52;
    final chartT = size.height * 0.65;
    final rect = Rect.fromLTWH(chartL, chartT, chartW, chartH);

    // Panel
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);

    const pad = 12.0;
    final innerRect = rect.deflate(pad);

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 4; i++) {
      final y = innerRect.top + innerRect.height * i / 4;
      canvas.drawLine(
          Offset(innerRect.left, y), Offset(innerRect.right, y), gridPaint);
    }

    // Build chart points
    final minV = _priceData.reduce(math.min);
    final maxV = _priceData.reduce(math.max);
    final range = maxV - minV;

    List<Offset> points = [];
    for (int i = 0; i < _priceData.length; i++) {
      final x = innerRect.left +
          innerRect.width * (i / (_priceData.length - 1));
      final normalized = range > 0 ? (_priceData[i] - minV) / range : 0.5;
      final y = innerRect.bottom - innerRect.height * normalized;
      points.add(Offset(x, y));
    }

    // Clip to animated progress
    final visibleCount = (points.length * chartProgress).ceil();
    if (visibleCount < 2) return;
    final visiblePoints = points.sublist(0, visibleCount);

    // Fill below line
    final fillPath = Path()..moveTo(visiblePoints.first.dx, innerRect.bottom);
    for (final p in visiblePoints) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(visiblePoints.last.dx, innerRect.bottom);
    fillPath.close();

    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF9800).withValues(alpha: 0.22),
              const Color(0xFFFF9800).withValues(alpha: 0.0),
            ],
          ).createShader(rect)
          ..style = PaintingStyle.fill);

    // Line
    final linePath = Path()..moveTo(visiblePoints.first.dx, visiblePoints.first.dy);
    for (int i = 1; i < visiblePoints.length; i++) {
      // Smooth cubic interpolation
      final prev = visiblePoints[i - 1];
      final curr = visiblePoints[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = const Color(0xFFFF9800)
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Data dots
    final dotPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;
    final dotBgPaint = Paint()
      ..color = const Color(0xFF131B35)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < visiblePoints.length; i++) {
      final p = visiblePoints[i];
      canvas.drawCircle(p, 4.5, dotBgPaint);
      canvas.drawCircle(p, 3.0, dotPaint);
    }

    // '€/L' label
    final label = TextPainter(
      text: TextSpan(
        text: '€/L',
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 9,
            letterSpacing: 0.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(innerRect.left + 2, innerRect.top + 2));
  }

  @override
  bool shouldRepaint(SplashGraphicPainter old) =>
      old.gaugeProgress != gaugeProgress ||
      old.chartProgress != chartProgress;
}
