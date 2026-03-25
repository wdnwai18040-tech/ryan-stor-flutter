import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

enum AppStatusType { completed, processing, neutral }

class StatusBadge extends StatefulWidget {
  final String label;
  final AppStatusType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(
      begin: 1,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.type == AppStatusType.processing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.type == AppStatusType.processing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.type != AppStatusType.processing &&
        _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: AppRadius.chip,
        boxShadow: style.shadow,
      ),
      child: Text(
        widget.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: style.fg,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    if (widget.type != AppStatusType.processing) return chip;

    return ScaleTransition(scale: _pulse, child: chip);
  }

  _BadgeStyle _resolveStyle() {
    switch (widget.type) {
      case AppStatusType.completed:
        return const _BadgeStyle(
          bg: Color(0xFFDCFCE7),
          fg: Color(0xFF15803D),
          shadow: [
            BoxShadow(
              color: Color(0x3322C55E),
              blurRadius: 10,
              spreadRadius: -4,
              offset: Offset(0, 4),
            ),
          ],
        );
      case AppStatusType.processing:
        return const _BadgeStyle(
          bg: Color(0xFFFEF3C7),
          fg: Color(0xFFB45309),
          shadow: [
            BoxShadow(
              color: Color(0x33F59E0B),
              blurRadius: 12,
              spreadRadius: -4,
              offset: Offset(0, 4),
            ),
          ],
        );
      case AppStatusType.neutral:
        return const _BadgeStyle(
          bg: Color(0xFFE2E8F0),
          fg: Color(0xFF334155),
          shadow: [],
        );
    }
  }
}

class _BadgeStyle {
  final Color bg;
  final Color fg;
  final List<BoxShadow> shadow;

  const _BadgeStyle({required this.bg, required this.fg, required this.shadow});
}
