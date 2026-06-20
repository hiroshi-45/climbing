import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 画面全体に薄いアンビエント光を敷く背景。Scaffold の body をこれで包む。
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.ambient),
      child: child,
    );
  }
}

/// うっすら境界の浮いたカード。タップ可能。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.gradientBorder = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// true ならサンセットのグラデーション枠線をまとう（強調用）。
  final bool gradientBorder;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    final content = Ink(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: radius,
        border: gradientBorder
            ? null
            : Border.all(color: AppPalette.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!gradientBorder) return content;

    // グラデ枠線：外側にグラデ、内側に surface 色を重ねて縁取りを表現。
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.sunset,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.all(1.5),
      child: content,
    );
  }
}

/// 文字にサンセットグラデーションをのせる。見出し・数値の強調に使う。
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppGradients.sunset,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

/// 0 から目標値まで弾むようにカウントアップする数値表示。
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.suffix = '',
    this.gradient,
    this.duration = const Duration(milliseconds: 900),
  });

  final int value;
  final TextStyle style;
  final String suffix;

  /// 指定するとグラデーション文字になる。
  final Gradient? gradient;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final text = '${v.round()}$suffix';
        if (gradient == null) {
          return Text(text, style: style);
        }
        return GradientText(text, style: style, gradient: gradient!);
      },
    );
  }
}

/// グレード等を表す小さな角丸ピル。
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color,
    this.filled = false,
    this.icon,
  });

  final String label;
  final Color? color;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppPalette.textMid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? c.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: filled ? 0.0 : 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 完登時のお祝い演出（紙吹雪）を画面前面にオーバーレイ表示する。
void showCelebration(BuildContext context, {String message = '完登！'}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationLayer(
      message: message,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _CelebrationLayer extends StatefulWidget {
  const _CelebrationLayer({required this.message, required this.onDone});
  final String message;
  final VoidCallback onDone;

  @override
  State<_CelebrationLayer> createState() => _CelebrationLayerState();
}

class _CelebrationLayerState extends State<_CelebrationLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    const colors = [
      AppPalette.sunsetStart,
      AppPalette.sunsetMid,
      AppPalette.sunsetEnd,
      AppPalette.sent,
      AppPalette.gold,
    ];
    _particles = List.generate(70, (_) {
      final angle = -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.1;
      final speed = 0.7 + rnd.nextDouble() * 0.9;
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        color: colors[rnd.nextInt(colors.length)],
        size: 6 + rnd.nextDouble() * 8,
        rotation: rnd.nextDouble() * math.pi * 2,
        spin: (rnd.nextDouble() - 0.5) * 0.4,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // メッセージは前半でポップ→後半でフェードアウト。
          final appear = Curves.elasticOut.transform(
            (t / 0.45).clamp(0.0, 1.0),
          );
          final fade = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
          return Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(_particles, t),
              ),
              Center(
                child: Opacity(
                  opacity: fade.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + appear * 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sunset,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.sunsetMid.withValues(alpha: 0.5),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.spin,
  });
  final double dx;
  final double dy;
  final Color color;
  final double size;
  final double rotation;
  final double spin;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.42);
    final spread = size.height * 0.9;
    final paint = Paint();
    for (final p in particles) {
      // 放物運動：初速で飛び、重力で落下。
      final x = origin.dx + p.dx * spread * t;
      final y = origin.dy + p.dy * spread * t + 0.9 * spread * t * t;
      final opacity = (1 - t).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.spin * t * 30);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
