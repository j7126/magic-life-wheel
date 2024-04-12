import 'package:flutter/material.dart';

class AnimatedFade extends StatefulWidget {
  const AnimatedFade({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.forwardDuration,
    this.reverseDuration,
  });

  final Widget child;
  final bool visible;
  final Duration? duration;
  final Duration? forwardDuration;
  final Duration? reverseDuration;

  @override
  State<AnimatedFade> createState() => _AnimatedFadeState();
}

class _AnimatedFadeState extends State<AnimatedFade> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.forwardDuration ?? widget.duration ?? Duration.zero,
    reverseDuration: widget.reverseDuration ?? widget.duration ?? Duration.zero,
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  bool last = false;

  @override
  void initState() {
    last = widget.visible;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (last != widget.visible) {
      last = widget.visible;
      if (widget.visible) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: 1);
      }
    }

    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
