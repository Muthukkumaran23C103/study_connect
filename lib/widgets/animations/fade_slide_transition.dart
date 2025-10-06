import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final AnimationController animation;
  final Duration delay;
  final Offset slideOffset;
  final Curve curve;

  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.animation,
    this.delay = Duration.zero,
    this.slideOffset = const Offset(0, 0.1),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay.inMilliseconds / animation.duration!.inMilliseconds,
          1.0,
          curve: curve,
        ),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(delayedAnimation);

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: delayedAnimation,
        child: child,
      ),
    );
  }
}

class ScaleTransition extends StatelessWidget {
  final Widget child;
  final AnimationController animation;
  final Duration delay;
  final double beginScale;
  final Curve curve;

  const ScaleTransition({
    super.key,
    required this.child,
    required this.animation,
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.curve = Curves.elasticOut,
  });

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay.inMilliseconds / animation.duration!.inMilliseconds,
          1.0,
          curve: curve,
        ),
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: beginScale,
      end: 1.0,
    ).animate(delayedAnimation);

    return Transform.scale(
      scale: scaleAnimation.value,
      child: FadeTransition(
        opacity: delayedAnimation,
        child: child,
      ),
    );
  }
}

class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final AnimationController animation;
  final Duration staggerDelay;
  final Offset slideOffset;
  final Curve curve;

  const StaggeredAnimation({
    super.key,
    required this.children,
    required this.animation,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.slideOffset = const Offset(0, 0.1),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return FadeSlideTransition(
          animation: animation,
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
          slideOffset: slideOffset,
          curve: curve,
          child: child,
        );
      }).toList(),
    );
  }
}