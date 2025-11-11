import 'package:flutter/material.dart';
import 'package:magic_life_wheel/static_service.dart';

class AnimatedScaleOnChange extends StatefulWidget {
  const AnimatedScaleOnChange({
    super.key,
    required this.child,
    required this.value,
    required this.duration,
    required this.scale,
    this.alignment,
    this.filter,
  });

  final Widget child;
  final int value;
  final Duration duration;
  final double scale;
  final Alignment? alignment;
  final bool Function(int prev, int next)? filter;

  @override
  State<AnimatedScaleOnChange> createState() => _AnimatedScaleOnChangeState();
}

class _AnimatedScaleOnChangeState extends State<AnimatedScaleOnChange> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    reverseDuration: widget.duration,
    vsync: this,
  );
  late final Animation<double> _animation = TweenSequence<double>([
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 1.0, end: widget.scale).chain(CurveTween(curve: Curves.linear)),
      weight: 1,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(
        begin: widget.scale,
        end: 1.0 + (widget.scale - 1.0) * 0.95,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 4,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: widget.scale, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 5,
    ),
  ]).animate(_controller);

  int last = 0;

  @override
  void initState() {
    last = widget.value;
    if (!Service.settingsService.pref_disableAnimations) {
      _controller.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (last != widget.value && !Service.settingsService.pref_disableAnimations) {
      if (widget.filter == null || widget.filter!(last, widget.value)) {
        _controller.forward(from: _controller.isCompleted ? 0 : 0.2);
      }
      last = widget.value;
    }

    return ScaleTransition(
      scale: _animation,
      alignment: widget.alignment ?? Alignment.center,
      child: widget.child,
    );
  }
}
