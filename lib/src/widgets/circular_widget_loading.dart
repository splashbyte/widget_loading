import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/clip.dart';
import 'package:widget_loading/src/utils/loading_state.dart';
import 'package:widget_loading/src/widgets/loading_widget.dart';
import 'package:widget_loading/src/widgets/widget_wrapper.dart';

typedef DotBuilder = Widget Function(int index, double radius);

class CircularWidgetLoading extends StatefulWidget {
  final Widget child;

  /// Indicates whether the widget/data is loaded.
  final bool loading;

  /// Indicates whether the animation should be played.
  final bool animating;

  /// Maximal size of the loading-circle. It's size will be smaller, if there is not enough space.
  final double maxLoadingCircleSize;

  /// Size of the biggest dot
  final double dotRadius;

  /// Size of the smallest dot relative to the [dotRadius]. Must be between 0 and 1.
  final double minDotRadiusFactor;

  /// [Duration] of the [AnimatedSize]. For deactivating AnimatedSize you can use [animatedSize].
  final Duration sizeDuration;

  /// [Duration] of the appearing/disappearing of the [child].
  final Duration appearingDuration;

  /// [Duration] of the loading-animation.
  final Duration loadingDuration;

  /// [Curve] of the AnimatedSize. For deactivating AnimatedSize you can use [animatedSize].
  final Curve sizeCurve;

  /// [Curve] of the appearing/disappearing of the [child].
  final Curve appearingCurve;

  /// [Curve] of the loading-animation.
  final Curve loadingCurve;

  /// [Color] of the dots
  final Color? dotColor;

  /// Padding of child
  final EdgeInsetsGeometry padding;

  /// Builder of the dots. If it is not set, the standard builder is used.
  final DotBuilder? dotBuilder;

  /// [Duration] of moving dots relative to the [loadingDuration]. Must be between 0 and 1.
  final double rollingDuration;

  /// [Duration] of the moving of a single dot relative to the [rollingDuration]. Must be between 0 and 1.
  final double rollingFactor;

  /// Count of the dots in the loading-circle.
  final int dotCount;

  /// Activating/deactivating [AnimatedSize] wrapper of [child].
  final bool animatedSize;

  /// Padding of LoadingCircle. Prevents it from touching the edges.
  final double loadingCirclePadding;

  /// [Duration] of the appearing animation of the dot.
  final Duration dotAppearingDuration;

  /// [Curve] of the appearing animation of the dot.
  final Curve dotAppearingCurve;

  /// Called when loading animation completed after setting [animating] or [loading] to [false].
  final VoidCallback? onLoadingAnimationCompleted;

  const CircularWidgetLoading({
    Key? key,
    this.loading = true,
    this.maxLoadingCircleSize = 75.0,
    this.sizeDuration = const Duration(milliseconds: 500),
    this.sizeCurve = Curves.linear,
    required this.child,
    this.dotRadius = 7.5,
    this.dotColor,
    this.appearingDuration = const Duration(milliseconds: 1000),
    this.loadingDuration = const Duration(milliseconds: 2000),
    this.appearingCurve = Curves.fastOutSlowIn,
    this.loadingCurve = Curves.easeInOutCirc,
    this.padding = EdgeInsets.zero,
    this.dotBuilder,
    this.rollingDuration = 1.0,
    this.dotCount = 5,
    this.rollingFactor = 0.875,
    this.animatedSize = true,
    this.minDotRadiusFactor = 0.5,
    this.loadingCirclePadding = 8.0,
    this.dotAppearingDuration = Duration.zero,
    this.dotAppearingCurve = Curves.easeOutBack,
    this.animating = true,
    this.onLoadingAnimationCompleted,
  }) : super(key: key);

  @override
  _CircularWidgetLoadingState createState() => _CircularWidgetLoadingState();
}

class _CircularWidgetLoadingState
    extends LoadingWidgetState<CircularWidgetLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _appearingController;
  late CurvedAnimation _appearingAnimation;
  late AnimationController _dotAppearingController;
  late CurvedAnimation _dotAppearingAnimation;
  List<CurvedAnimation> _animations = [];

  final _childKey = GlobalKey();
  final _animatedSizeKey = GlobalKey();

  Widget _child = SizedBox();

  @override
  void initState() {
    super.initState();

    assert(widget.rollingDuration >= 0 && widget.rollingDuration <= 1);
    assert(widget.rollingFactor >= 0 && widget.rollingFactor <= 1);
    assert(widget.minDotRadiusFactor >= 0 && widget.minDotRadiusFactor <= 1);

    _child = widget.child;

    _dotAppearingController =
        AnimationController(vsync: this, duration: widget.dotAppearingDuration)
          ..forward();

    _dotAppearingAnimation = CurvedAnimation(
        parent: _dotAppearingController, curve: widget.dotAppearingCurve);

    _appearingController = AnimationController(
      duration: widget.appearingDuration,
      vsync: this,
    )..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.dismissed:
            if (disappearing) {
              loadingState = LoadingState.LOADING;
              if (widget.animating) _controller.forward(from: 0.0);
            }
            break;
          case AnimationStatus.completed:
            if (appearing) loadingState = LoadingState.LOADED;
            break;
          case AnimationStatus.forward:
            break;
          case AnimationStatus.reverse:
            break;
        }
      });

    _appearingAnimation = CurvedAnimation(
        parent: _appearingController, curve: widget.appearingCurve);

    _controller = AnimationController(
      duration: widget.loadingDuration,
      vsync: this,
    )..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.forward:
            break;
          case AnimationStatus.reverse:
            break;
          case AnimationStatus.dismissed:
            break;
          case AnimationStatus.completed:
            if (!widget.loading && loading) {
              loadingState = LoadingState.APPEARING;
              _appearingController.forward(from: 0.0);
              widget.onLoadingAnimationCompleted?.call();
            } else if (widget.animating) {
              _controller.forward(from: 0.0);
            } else {
              widget.onLoadingAnimationCompleted?.call();
            }
            break;
        }
      });

    _generateDotAnimations();
    _setDotCurves();

    setLoadingState(widget.loading ? LoadingState.LOADING : LoadingState.LOADED,
        rebuild: false);
    if (loading)
      _controller.forward();
    else
      _appearingController.value = 1.0;
  }

  void _generateDotAnimations() {
    _animations.forEach((a) => a.dispose());
    _animations = List.generate(widget.dotCount,
        (index) => CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  void _setDotCurves() {
    double dif = _animations.length <= 1
        ? 0
        : widget.rollingDuration *
            (1 - widget.rollingFactor) /
            (_animations.length - 1);
    double singleRollingDuration =
        widget.rollingDuration * widget.rollingFactor;
    for (int i = 0; i < _animations.length; i++) {
      _animations[i].curve = Interval(i * dif, singleRollingDuration + i * dif,
          curve: widget.loadingCurve);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _appearingController.dispose();
    _dotAppearingController.dispose();
    super.dispose();
  }

  Widget get _animatedSizeWidget {
    final wrappedChild = WidgetWrapper(key: _childKey, child: _child);

    return Padding(
      padding: widget.padding,
      child: IgnorePointer(
          ignoring: !loaded,
          child: widget.animatedSize
              ? AnimatedSize(
                  key: _animatedSizeKey,
                  duration: widget.sizeDuration,
                  curve: widget.sizeCurve,
                  child: wrappedChild)
              : wrappedChild),
    );
  }

  @override
  void didUpdateWidget(covariant CircularWidgetLoading oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_animations.length != widget.dotCount) _generateDotAnimations();
    if (_animations.length != widget.dotCount ||
        oldWidget.rollingFactor != widget.rollingFactor ||
        oldWidget.rollingDuration != widget.rollingFactor ||
        oldWidget.loadingCurve != widget.loadingCurve) _setDotCurves();

    _appearingController.duration = widget.appearingDuration;
    _appearingAnimation.curve = widget.appearingCurve;
    _controller.duration = widget.loadingDuration;

    if ((loaded || appearing) && widget.loading) {
      setLoadingState(LoadingState.DISAPPEARING, rebuild: false);
      _appearingController.reverse();
    } else if (disappearing && !widget.loading) {
      setLoadingState(LoadingState.APPEARING, rebuild: false);
      _appearingController.forward();
    }

    if (widget.animating &&
        widget.loading &&
        !_controller.isAnimating &&
        !_appearingController.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!disappearing) _child = widget.child;
    ThemeData theme = Theme.of(context);
    Widget loadedChild = _animatedSizeWidget;
    Color dotColor = widget.dotColor ?? theme.colorScheme.secondary;
    TextDirection textDirection =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    Widget stack = Stack(
      children: [
        if (loading) ...[
          WidgetSizedBox(
            child: loadedChild,
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double radius = min(
                            widget.maxLoadingCircleSize,
                            min(constraints.maxWidth, constraints.maxHeight) -
                                2 * widget.loadingCirclePadding) /
                        2 -
                    widget.dotRadius;
                double x = constraints.maxWidth / 2;
                double y = constraints.maxHeight / 2;

                return AnimatedBuilder(
                  animation: _dotAppearingAnimation,
                  builder: (context, _) => Stack(
                      children: List.generate(_animations.length, (index) {
                    Animation animation = _animations[index];
                    double dotRadius = _dotAppearingAnimation.value *
                        widget.dotRadius *
                        (widget.minDotRadiusFactor +
                            (1 - widget.minDotRadiusFactor) *
                                (1 - index / _animations.length));
                    return AnimatedBuilder(
                        animation: animation,
                        child: widget.dotBuilder?.call(index, dotRadius) ??
                            loadingPoint(dotRadius, dotColor),
                        builder: (context, child) {
                          double radian = 0.5 * pi - 2 * pi * animation.value;
                          return Positioned(
                            child: child!,
                            top: y - radius * sin(radian) - dotRadius,
                            left: x - radius * cos(radian) - dotRadius,
                          );
                        });
                  })),
                );
              },
            ),
          ),
        ] else if (loaded)
          loadedChild
        else
          AnimatedBuilder(
            animation: _appearingAnimation,
            builder: (context, child) => ClipOval(
              clipper: DotClipper(_appearingAnimation.value, widget.dotRadius,
                  widget.maxLoadingCircleSize, widget.loadingCirclePadding),
              child: Stack(children: [
                DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                        color: dotColor.withOpacity(dotColor.opacity *
                            (1 - _appearingAnimation.value))),
                    child: loadedChild)
              ]),
            ),
          )
      ],
    );
    return Directionality(textDirection: textDirection, child: stack);
  }

  Widget loadingPoint(double radius, Color color) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }
}
