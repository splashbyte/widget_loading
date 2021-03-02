import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/loading_state.dart';
import 'package:widget_loading/src/widgets/loading_widget.dart';
import 'package:widget_loading/src/widgets/wiper_loading.dart';

typedef DotBuilder = Widget Function(double radius);

class CircularWidgetLoading extends StatefulWidget {
  final Widget child;

  /// Indicates whether the widget/data is loaded.
  final bool loading;

  /// Maximal size of the loading-circle. It's size will be smaller, if there is not enough space.
  final double maxLoadingCircleSize;

  /// Size of the biggest dot
  final double dotRadius;

  /// Size of the smallest dot relative to the [dotRadius]. Must be between 0 and 1.
  final double minDotRadiusFactor;

  /// Duration of the AnimatedSize. For deactivating AnimatedSize you can use [animatedSize].
  final Duration sizeDuration;

  /// Duration of the appearing/disappearing of the [child].
  final Duration appearingDuration;

  /// Duration of the loading-animation.
  final Duration loadingDuration;

  /// Curve of the AnimatedSize. For deactivating AnimatedSize you can use [animatedSize].
  final Curve sizeCurve;

  /// Curve of the appearing/disappearing of the [child].
  final Curve appearingCurve;

  /// Curve of the loading-animation.
  final Curve loadingCurve;

  /// Color of the dots
  final Color? dotColor;

  /// Padding of child
  final EdgeInsetsGeometry padding;

  /// Builder of the dots. If it is not set, the standard builder is used.
  final DotBuilder? dotBuilder;

  /// Duration of moving dots relative to the [loadingDuration]. Must be between 0 and 1.
  final double rollingDuration;

  /// Duration of the moving of a single dot relative to the [rollingDuration]. Must be between 0 and 1.
  final double rollingFactor;

  /// Count of the dots in the loading-circle.
  final int dotCount;

  /// Activating/deactivating AnimatedSize-Wrapper of [child].
  final bool animatedSize;

  /// Padding of LoadingCircle. Prevents it from touching the edges.
  final double loadingCirclePadding;

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
    this.padding = const EdgeInsets.all(10.0),
    this.dotBuilder,
    this.rollingDuration = 0.8,
    this.dotCount = 5,
    this.rollingFactor = 0.7,
    this.animatedSize = true,
    this.minDotRadiusFactor = 0.5,
    this.loadingCirclePadding = 8.0,
  }) : super(key: key);

  @override
  _CircularWidgetLoadingState createState() => _CircularWidgetLoadingState();
}

class _CircularWidgetLoadingState extends State<CircularWidgetLoading> with TickerProviderStateMixin, LoadingWidget {
  late AnimationController _controller;
  late AnimationController _appearingController;
  late Animation<double> _appearingAnimation;
  List<Animation<double>> _animations = [];

  final _childKey = GlobalKey();

  Widget _child = Container();

  @override
  void initState() {
    super.initState();

    assert(widget.rollingDuration >= 0 && widget.rollingDuration <= 1);
    assert(widget.rollingFactor >= 0 && widget.rollingFactor <= 1);
    assert(widget.minDotRadiusFactor >= 0 && widget.minDotRadiusFactor <= 1);

    loadingState = widget.loading ? LoadingState.LOADING : LoadingState.LOADED;

    _child = widget.child;

    _appearingController = AnimationController(
      duration: widget.appearingDuration,
      vsync: this,
    )
      ..addListener(() {
        if (!appearing && !disappearing) return;
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.dismissed:
            if (disappearing) {
              loadingState = LoadingState.LOADING;
              _controller.forward(from: 0.0);
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

    _appearingAnimation = CurvedAnimation(parent: _appearingController, curve: widget.appearingCurve);

    _controller = AnimationController(
      duration: widget.loadingDuration,
      vsync: this,
    )
      ..addListener(() {
        if (!loading) return;
        setState(() {});
      })
      ..addStatusListener((status) {
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
            } else
              WidgetsBinding.instance?.addPostFrameCallback((_) => _controller.forward(from: 0.0));
            break;
        }
      });

    double dif = widget.dotCount <= 1 ? 0 : widget.rollingDuration * (1 - widget.rollingFactor) / (widget.dotCount - 1);
    double singleRollingDuration = widget.rollingDuration * widget.rollingFactor;
    for (int i = 0; i < widget.dotCount; i++) {
      _animations.add(CurvedAnimation(
          parent: _controller, curve: Interval(i * dif, singleRollingDuration + i * dif, curve: widget.loadingCurve)));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _appearingController.dispose();
    super.dispose();
  }

  Widget animatedSizeWidget(Key key) => Stack(
        children: [
          //Container(width: widget.minWidth, height: widget.minHeight,),
          Padding(
            padding: widget.padding,
            child: widget.animatedSize
                ? AnimatedSize(
                    key: key, duration: widget.sizeDuration, vsync: this, curve: widget.sizeCurve, child: _child)
                : Container(key: key, child: _child),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if ((loaded || appearing) && widget.loading) {
      loadingState = LoadingState.DISAPPEARING;
      _appearingController.reverse();
    } else if (disappearing && !widget.loading) {
      loadingState = LoadingState.APPEARING;
      _appearingController.forward();
    }

    if (!disappearing) _child = widget.child;

    Widget loadedChild = animatedSizeWidget(_childKey);
    ThemeData theme = Theme.of(context);
    Color dotColor = widget.dotColor ?? theme.accentColor;
    TextDirection textDirection = Directionality.maybeOf(context)??TextDirection.ltr;

    Widget stack = Stack(
      children: [
        if (loading)
          WidgetSizedBox(
            child: loadedChild,
          ),
        if (loaded)
          loadedChild
        else if (appearing || disappearing)
          ClipOval(
            clipper: DotClipper(
                _appearingAnimation.value, widget.dotRadius, widget.maxLoadingCircleSize, widget.loadingCirclePadding),
            child: Stack(children: [
              Container(
                  foregroundDecoration:
                      BoxDecoration(color: dotColor.withOpacity(dotColor.opacity * (1 - _appearingAnimation.value))),
                  child: loadedChild)
            ]),
          )
        else
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double radius = min(widget.maxLoadingCircleSize,
                            min(constraints.maxWidth, constraints.maxHeight) - 2 * widget.loadingCirclePadding) /
                        2 -
                    widget.dotRadius;
                double x = constraints.maxWidth / 2;
                double y = constraints.maxHeight / 2;

                return Stack(
                    children: List.generate(_animations.length, (index) => index).map((i) {
                  Animation animation = _animations[i];
                  double radian = 0.5 * pi - 2 * pi * animation.value;
                  double dotRadius = widget.dotRadius *
                      (widget.minDotRadiusFactor + (1 - widget.minDotRadiusFactor) * (1 - i / _animations.length));
                  return Positioned(
                    child: widget.dotBuilder?.call(widget.dotRadius) ?? loadingPoint(dotRadius),
                    top: y - radius * sin(radian) - dotRadius,
                    left: x - radius * cos(radian) - dotRadius,
                  );
                }).toList());
              },
            ),
          ),
      ],
    );
    return Directionality(textDirection: textDirection, child: stack);

    /*return Stack(
      children: [
        WidgetSizedBox(
          child: animatedSizeWidget(pseudoChildKey),
        ),
        loaded
            ? loadedChild
            : Positioned.fill(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double radius = min(widget.maxLoadingCircleSize ?? double.infinity,
                                min(constraints.maxWidth, constraints.maxHeight)) /
                            2 -
                        widget.dotRadius / 2;
                    double x = constraints.maxWidth / 2;
                    double y = constraints.maxHeight / 2;

                    double maxAppearingRadius = max(constraints.maxWidth, constraints.maxHeight) / 2;
                    double appearingRadius =
                        widget.dotRadius + _appearingAnimation.value * (maxAppearingRadius - widget.dotRadius);
                    return Container(
                      child: appearing || disappearing
                          ? ClipOval(
                              clipper:
                                  CircleClipper(x + widget.dotRadius, y - radius + widget.dotRadius, appearingRadius),
                              child: Stack(children: [
                                loadedChild,
                                Opacity(
                                    opacity: 1 - appearingRadius / maxAppearingRadius,
                                    child: Container(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      color: widget.dotColor ?? theme.accentColor,
                                    ))
                              ]),
                            )
                          : Stack(
                              children: <Widget>[
                                    WidgetSizedBox(
                                      child: loadedChild,
                                    ),
                                  ] +
                                  _animations.map((e) {
                                    double radian = 0.5 * pi - 2 * pi * e.value;
                                    return Positioned(
                                      child:
                                          widget.dotBuilder?.call(widget.dotRadius) ?? loadingPoint(widget.dotRadius),
                                      top: y - radius * sin(radian),
                                      left: x - radius * cos(radian),
                                    );
                                  }).toList()),
                    );
                  },
                ),
              ),
      ],
    );*/
  }

  Widget loadingPoint(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
          color: widget.dotColor ?? Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(radius))),
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  final double radius;
  final double x, y;

  CircleClipper(this.x, this.y, this.radius);

  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(center: Offset(x, y), radius: radius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return this != oldClipper;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircleClipper &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => radius.hashCode ^ x.hashCode ^ y.hashCode;
}

class DotClipper extends CustomClipper<Rect> {
  final double factor;
  final double dotRadius;
  final double maxLoadingCircleSize;
  final double loadingCirclePadding;

  DotClipper(this.factor, this.dotRadius, this.maxLoadingCircleSize, this.loadingCirclePadding);

  @override
  Rect getClip(Size size) {
    double radius =
        min(maxLoadingCircleSize, min(size.width, size.height) - 2 * loadingCirclePadding) / 2 -
            dotRadius;
    double x = size.width / 2;
    double y = size.height / 2;

    double maxAppearingRadius = sqrt(x * x + y * y);
    double appearingRadius = dotRadius + factor * (maxAppearingRadius - dotRadius);
    return Rect.fromCircle(center: Offset(x, y - radius), radius: appearingRadius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return this != oldClipper;
  }
}
