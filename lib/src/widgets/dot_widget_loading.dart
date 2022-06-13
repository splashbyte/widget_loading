import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/clip.dart';
import 'package:widget_loading/src/utils/loading_state.dart';
import 'package:widget_loading/src/widgets/loading_widget.dart';
import 'package:widget_loading/src/widgets/widget_wrapper.dart';

typedef AnimatedDotBuilder = Widget Function(double radius);

class DotWidgetLoading extends StatefulWidget {
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

  final double dotInterval;

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
  final AnimatedDotBuilder? dotBuilder;

  /// Activating/deactivating AnimatedSize-Wrapper of [child].
  final bool animatedSize;

  /// Padding of LoadingCircle. Prevents it from touching the edges.
  final double loadingCirclePadding;

  const DotWidgetLoading({
    Key? key,
    this.loading = true,
    this.maxLoadingCircleSize = 75.0,
    this.sizeDuration = const Duration(milliseconds: 500),
    this.sizeCurve = Curves.linear,
    required this.child,
    this.dotRadius = 50.0,
    this.dotColor,
    this.appearingDuration = const Duration(milliseconds: 1000),
    this.loadingDuration = const Duration(milliseconds: 2500),
    this.appearingCurve = Curves.fastOutSlowIn,
    this.loadingCurve = Curves.linear,
    this.padding = EdgeInsets.zero,
    this.dotBuilder,
    this.animatedSize = true,
    this.minDotRadiusFactor = 0.5,
    this.loadingCirclePadding = 8.0,
    this.dotInterval = 0.3,
  }) : super(key: key);

  @override
  _DotWidgetLoadingState createState() => _DotWidgetLoadingState();
}

class _DotWidgetLoadingState extends LoadingWidgetState<DotWidgetLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _appearingController;
  late CurvedAnimation _appearingAnimation;
  List<CurvedAnimation> _animations = [];

  final _childKey = GlobalKey();
  final _animatedSizeKey = GlobalKey();

  Widget _child = SizedBox();

  @override
  void initState() {
    super.initState();

    assert(widget.minDotRadiusFactor >= 0 && widget.minDotRadiusFactor <= 1);

    _child = widget.child;

    _appearingController = AnimationController(
      duration: widget.appearingDuration,
      vsync: this,
    )..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.dismissed:
            if (disappearing) loadingState = LoadingState.LOADING;
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
    );

    _generateDotAnimations();

    setLoadingState(widget.loading ? LoadingState.LOADING : LoadingState.LOADED,
        rebuild: false);
    if (loading)
      _controller.repeat();
    else
      _appearingController.value = 1.0;
  }

  void _generateDotAnimations() {
    _animations.forEach((a) => a.dispose());
    int dotCount = (1 / widget.dotInterval).ceil();
    double factor = widget.dotInterval * dotCount;
    _controller.duration = widget.loadingDuration * factor;
    _animations = List.generate(
        dotCount,
        (index) => CurvedAnimation(
            parent: _controller,
            curve: _RepeatingInterval(index * widget.dotInterval / factor,
                (1.0 + (index * widget.dotInterval) / factor),
                curve: widget.loadingCurve)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _appearingController.dispose();
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
  void didUpdateWidget(covariant DotWidgetLoading oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_animations.length != widget.dotInterval ||
        oldWidget.dotInterval != widget.dotInterval ||
        oldWidget.loadingCurve != widget.loadingCurve) _generateDotAnimations();

    _appearingController.duration = widget.appearingDuration;
    _appearingAnimation.curve = widget.appearingCurve;
    _controller.duration = widget.loadingDuration;

    if ((loaded || appearing) && widget.loading) {
      setLoadingState(LoadingState.DISAPPEARING, rebuild: false);
      _appearingController.reverse();
    } else if (disappearing && !widget.loading) {
      setLoadingState(LoadingState.APPEARING, rebuild: false);
      _appearingController.forward();
    } else if (oldWidget.loading != widget.loading) {
      if (widget.loading) {
        _appearingController.reverse(from: 1.0);
        setLoadingState(LoadingState.DISAPPEARING, rebuild: false);
      } else {
        _appearingController.forward(from: 0.0);
        setLoadingState(LoadingState.APPEARING, rebuild: false);
      }
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
        if (!loaded) ...[
          if (loading)
            WidgetSizedBox(
              child: loadedChild,
            ),
          Positioned.fill(
            child: AnimatedBuilder(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var a in _animations)
                        AnimatedBuilder(
                            animation: a,
                            builder: (context, _) {
                              return loadingPoint(a.value);
                            }),
                    ],
                  );
                },
              ),
              animation: _appearingAnimation,
              builder: (context, child) => ClipPath(
                clipBehavior: loading ? Clip.none : Clip.antiAlias,
                clipper: appearing
                    ? InvertedDotClipper(_appearingAnimation.value)
                    : PathDotClipper(1.0 - _appearingAnimation.value),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: appearing ? Colors.transparent : dotColor.withOpacity(dotColor.opacity *
                            (_appearingAnimation.value))),
                    child: child),
              ),
            ),
          ),
        ] else
          loadedChild,
        if (appearing || disappearing)
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _appearingAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      ClipPath(
                        clipper: appearing
                            ? PathDotClipper(_appearingAnimation.value)
                            : InvertedDotClipper(
                                1.0 - _appearingAnimation.value),
                        child: loadedChild,
                      ),
                    ],
                  );
                },
              );
            },
          )
      ],
    );
    return Directionality(textDirection: textDirection, child: stack);
  }

  Widget loadingPoint(double value) {
    return Center(
      child: Container(
        width: widget.dotRadius * 2 * value,
        height: widget.dotRadius * 2 * value,
        decoration: BoxDecoration(
          color: (widget.dotColor ?? Theme.of(context).primaryColor)
              .withOpacity(1.0 - value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _RepeatingInterval extends Curve {
  const _RepeatingInterval(this.begin, this.end, {this.curve = Curves.linear})
      : assert(begin <= 1.0, begin >= 0.0 && end >= 0.0 && begin != end);
  final double begin;
  final double end;
  final Curve curve;

  @override
  double transformInternal(double t) {
    double begin = this.begin;
    double end = this.end;
    if (end < 1.0) end += 1.0;
    if (t < begin) {
      begin -= 1.0;
      end -= 1.0;
    }
    t = ((t - begin) / (end - begin)).clamp(0.0, 1.0);
    if (t == 0.0 || t == 1.0) return t;
    return curve.transform(t);
  }

  @override
  String toString() {
    return '_RepeatingInterval{begin: $begin, end: $end, curve: $curve}';
  }
}
