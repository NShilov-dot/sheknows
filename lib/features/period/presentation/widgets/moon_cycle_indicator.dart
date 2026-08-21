import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/cycle_stats.dart';

/// The Lunar Bloom signature element: a moon that waxes and wanes with the
/// user's cycle.
///
/// Day 1 of the cycle is the new moon; ovulation (~mid-cycle) is the full
/// moon. Renders as a glowing disc plus the phase name and cycle day.
class MoonCycleIndicator extends StatelessWidget {
  const MoonCycleIndicator({super.key, required this.stats, this.size = 96});

  final CycleStats stats;
  final double size;

  /// Cycle length used for phase mapping; falls back to 28 days when there
  /// are not yet enough logged periods to compute an average.
  int get _cycleLength {
    final average = stats.averageCycleLength;
    if (average != null && average > 0) {
      return average;
    }
    return 28;
  }

  /// Progress through the cycle: 0 = day 1 (new moon), 0.5 = mid-cycle
  /// (full moon), just under 1 = eve of the next period.
  double get _phase {
    final day = stats.currentCycleDay ?? 1;
    return ((day - 1) / _cycleLength).clamp(0.0, 0.999);
  }

  String get _phaseName {
    const names = [
      ('New moon', 'Your period is arriving or has just started'),
      ('Waxing crescent', 'Follicular phase — energy is building'),
      ('First quarter', 'Follicular phase — momentum'),
      ('Waxing gibbous', 'Approaching ovulation'),
      ('Full moon', 'Ovulation window'),
      ('Waning gibbous', 'Luteal phase — wind down'),
      ('Last quarter', 'Luteal phase'),
      ('Waning crescent', 'Late luteal — be gentle with yourself'),
    ];
    final index = (_phase * names.length).floor().clamp(0, names.length - 1);
    return names[index].$1;
  }

  String get _phaseHint {
    const hints = [
      'Your period is here or about to arrive',
      'Energy is building',
      'Steady momentum',
      'Ovulation is approaching',
      'Peak of your cycle',
      'Wind-down begins',
      'Reflect and rest',
      'Be gentle with yourself',
    ];
    final index = (_phase * hints.length).floor().clamp(0, hints.length - 1);
    return hints[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final day = stats.currentCycleDay;

    return Column(
      children: [
        _GlowingMoon(phase: _phase, size: size),
        if (day != null) ...[
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.onSurface,
              ),
              children: [
                TextSpan(text: 'Day $day'),
                TextSpan(
                  text: ' of $_cycleLength',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_phaseName · ${_phaseHint.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlowingMoon extends StatelessWidget {
  const _GlowingMoon({required this.phase, required this.size});

  final double phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size + 24,
      height: size + 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.18),
            scheme.primary.withValues(alpha: 0.02),
            Colors.transparent,
          ],
          stops: const [0.55, 0.8, 1],
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(size),
          painter: _MoonPainter(
            phase: phase,
            litColor: scheme.secondary,
            shadowColor:
                scheme.onSurface.withValues(alpha: 0.12),
            glowColor: scheme.primary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}

/// Draws the moon disc and its illuminated portion for [phase] in [0, 1).
///
/// Geometry: the lit region is bounded by the outer limb arc on one side and
/// a terminator half-ellipse on the other. The terminator's x-radius is
/// `R * |cos(2π·phase)|` and it bulges toward the lit side when
/// `cos(2π·phase) > 0`, away from it when negative — producing crescent,
/// quarter, and gibbous shapes automatically.
class _MoonPainter extends CustomPainter {
  _MoonPainter({
    required this.phase,
    required this.litColor,
    required this.shadowColor,
    required this.glowColor,
  });

  final double phase;
  final Color litColor;
  final Color shadowColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Soft halo.
    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()..color = glowColor,
    );

    // Dark base disc with subtle rim light.
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          shadowColor.withValues(alpha: 0.9),
          shadowColor.withValues(alpha: 0.65),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    final p = phase.clamp(0.0, 1.0);

    // Illumination fraction driver: 1 at new moon, 0 at quarters,
    // -1 at full moon.
    final k = math.cos(2 * math.pi * p);

    // Full moon shortcut.
    if (p >= 0.495 && p <= 0.505) {
      canvas.drawCircle(center, radius, Paint()..color = litColor);
      return;
    }
    // New moon shortcut — only the base disc.
    if (k.abs() < 0.01 && (p < 0.005 || p > 0.995)) {
      return;
    }

    final waxing = p <= 0.5;
    final limbSweep =
        waxing ? math.pi : -math.pi; // waxing lights the right side...
    // ...waning lights the left side.
    final terminatorSweep = waxing
        ? (k > 0 ? -math.pi : math.pi)
        : (k > 0 ? math.pi : -math.pi);

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        limbSweep,
        false,
      )
      ..arcTo(
        Rect.fromCenter(
          center: center,
          width: (k.abs() * radius) * 2,
          height: radius * 2,
        ),
        math.pi / 2,
        terminatorSweep,
        false,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = litColor);
  }

  @override
  bool shouldRepaint(_MoonPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.litColor != litColor ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.glowColor != glowColor;
}
