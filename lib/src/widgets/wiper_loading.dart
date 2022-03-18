import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/extensions.dart';
import 'package:widget_loading/src/utils/loading_state.dart';
import 'package:widget_loading/src/widgets/widget_wrapper.dart';

import 'loading_widget.dart';

enum WiperDirection {
  up,
  down,
  left,
  right,
}

typedef WiperBuilder = Widget Function(double width, double height);

class WiperLoading extends StatefulWidget {
  /// Min width of the wiper widget.
  final double minWidth;

  /// Min width of the wiper widget.
  final double minHeight;

  final Widget child;

  /// Curve of the wiper animation.
  final Curve curve;

  /// Duration of the wiper animation.
  final Duration interval;

  /// Indicates whether the widget/data is loaded.
  final bool loading;

  /// Standard width of the wiper.
  final double wiperWidth;

  /// Color of the wiper animation if the [wiperBuilder] is null
  final Color? wiperColor;

  /// Curve of the AnimatedSize. For deactivating animatedSize you can use [animatedSize].
  final Curve sizeCurve;

  /// Duration of the AnimatedSize. For deactivating animatedSize you can use [animatedSize].
  final Duration sizeDuration;

  /// Activating/deactivating AnimatedSize-Wrapper of [child].
  final bool animatedSize;

  /// Factor for manipulating the size of the wiper based on its current speed. For deactivating the deforming you have to set it to zero.
  final double wiperDeformingFactor;

  /// Builder of the wiper. If this is not set, the standard wiper will be shown.
  final WiperBuilder? wiperBuilder;

  /// Direction of the wiper.
  final WiperDirection direction;

  const WiperLoading({
    Key? key,
    this.minWidth = 0,
    this.minHeight = 0,
    required this.child,
    this.interval = const Duration(milliseconds: 750),
    this.loading = true,
    this.wiperColor,
    this.sizeCurve = Curves.linear,
    this.sizeDuration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCirc,
    this.wiperBuilder,
    this.animatedSize = true,
    this.wiperDeformingFactor = 0.5,
    this.wiperWidth = 15.0,
    this.direction = WiperDirection.right,
  }) : super(key: key);

  static Widget future({
    Key? key,
    required Future<Widget> future,
    double minWidth = 50,
    double minHeight = 50,
    Duration interval = const Duration(milliseconds: 750),
    Color? wiperColor,
    Curve sizeCurve = Curves.linear,
    Duration sizeDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOutCirc,
    WiperBuilder? wiperBuilder,
    bool animatedSize = true,
    double wiperDeformingFactor = 0.5,
    double wiperWidth = 15.0,
    WiperDirection direction = WiperDirection.right,
  }) {
    return FutureBuilder<Widget>(
        key: key,
        future: future,
        builder: (c, a) {
          return WiperLoading(
            child: a.data ?? Container(width: 0, height: 0),
            loading: !a.hasData,
            minWidth: minWidth,
            minHeight: minHeight,
            interval: interval,
            wiperColor: wiperColor,
            sizeCurve: sizeCurve,
            sizeDuration: sizeDuration,
            curve: curve,
            wiperBuilder: wiperBuilder,
            animatedSize: animatedSize,
            wiperDeformingFactor: wiperDeformingFactor,
            wiperWidth: wiperWidth,
            direction: direction,
          );
        });
  }

  @override
  _WiperLoadingState createState() => _WiperLoadingState();
}

class _WiperLoadingState extends LoadingWidgetState<WiperLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  final _animatedSizeKey = GlobalKey();
  double _pointPosition = 0;
  late Widget _child;

  final _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _child = widget.child;

    setLoadingState(widget.loading ? LoadingState.LOADING : LoadingState.LOADED,
        rebuild: false);

    _controller = AnimationController(
      duration: widget.interval,
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve)
      ..addListener(() {
        if (loaded) return;
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.forward:
            if (!widget.loading && loading && !appearing) {
              loadingState = LoadingState.APPEARING;
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                _controller.animateTo(1.0);
              });
            }
            break;
          case AnimationStatus.reverse:
            if (widget.loading && !loading && !disappearing) {
              loadingState = LoadingState.DISAPPEARING;
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                _controller.animateBack(0.0);
              });
            }
            break;
          case AnimationStatus.dismissed:
            if (disappearing) {
              loadingState = LoadingState.LOADING;
              _controller.repeat(reverse: true);
            }
            break;
          case AnimationStatus.completed:
            if (appearing) loadingState = LoadingState.LOADED;
            break;
        }
      });

    if(loaded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _loadingWiper(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(min(width, height))),
        child: Container(
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget animatedSizeWidget(Key key) {
    final wrappedChild = WidgetWrapper(key: _childKey, child: _child);
    return Stack(
      children: [
        SizedBox(
          width: widget.minWidth,
          height: widget.minHeight,
        ),
        IgnorePointer(
          ignoring: !loaded,
          child: widget.animatedSize
              ? AnimatedSize(
                  key: _animatedSizeKey,
                  duration: widget.sizeDuration,
                  curve: widget.sizeCurve,
                  child: wrappedChild)
              : wrappedChild,
        ),
      ],
    );
  }

  bool get up => widget.direction == WiperDirection.up;

  bool get down => widget.direction == WiperDirection.down;

  bool get right => widget.direction == WiperDirection.right;

  bool get left => widget.direction == WiperDirection.left;

  @override
  void didUpdateWidget(covariant WiperLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (loaded && widget.loading) {
      setLoadingState(LoadingState.DISAPPEARING, rebuild: false);
      _controller.animateBack(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!disappearing) _child = widget.child;

    Widget _loadedChild = animatedSizeWidget(_childKey);
    Color color = widget.wiperColor ?? Theme.of(context).colorScheme.secondary;

    bool vertical = up || down;
    TextDirection textDirection =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    Widget stack = Stack(
      children: [
        if (loaded)
          _loadedChild
        else ...[
          appearing || disappearing
              ? AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => ClipRect(
                    clipper:
                        _WiperRectClipper(widget.direction, _animation.value),
                    child: _loadedChild,
                  ),
                )
              : WidgetSizedBox(
                  child: _loadedChild,
                ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Size biggest = constraints.biggest;
                double height =
                    constraints.hasBoundedHeight ? biggest.height : 50;
                double width = biggest.width;
                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    double _circleWidth = widget.wiperWidth *
                        (1 +
                            _animation.speed.abs() *
                                widget.wiperDeformingFactor) *
                        (appearing || disappearing ? 1 - _animation.value : 1);
                    Widget wiper = widget.wiperBuilder?.call(
                            vertical ? width : _circleWidth,
                            vertical ? _circleWidth : height) ??
                        _loadingWiper(vertical ? width : _circleWidth,
                            vertical ? _circleWidth : height, color);
                    _pointPosition = (_animation.value *
                        ((vertical ? height : width) - _circleWidth));
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
                          Positioned(
                            left: right ? _pointPosition : null,
                            right: left ? _pointPosition : null,
                            top: down ? _pointPosition : null,
                            bottom: up ? _pointPosition : null,
                            child: wiper,
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
    return Directionality(textDirection: textDirection, child: stack);
  }
}

class _WiperRectClipper extends CustomClipper<Rect> {
  final WiperDirection direction;
  final double factor;

  _WiperRectClipper(this.direction, this.factor);

  @override
  Rect getClip(Size size) {
    return direction == WiperDirection.left
        ? Rect.fromLTWH(size.width * (1 - factor), 0, size.width * factor, size.height)
        : direction == WiperDirection.right
            ? Rect.fromLTWH(0, 0, size.width * factor, size.height)
            : direction == WiperDirection.up
                ? Rect.fromLTWH(0, size.height * (1 - factor), size.width, size.height * factor)
                : Rect.fromLTWH(0, 0, size.width, size.height * factor);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return this != oldClipper;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _WiperRectClipper && runtimeType == other.runtimeType && direction == other.direction && factor == other.factor;

  @override
  int get hashCode => direction.hashCode ^ factor.hashCode;
}
