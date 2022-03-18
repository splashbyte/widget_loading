import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/loading_state.dart';

// unused because of problems with documentation of constructor parameters
abstract class LoadingWidget extends StatefulWidget {
  final Widget child;

  /// Indicates whether the widget/data is loaded.
  final bool loading;

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

  /// Padding of child
  final EdgeInsetsGeometry padding;

  /// Activating/deactivating AnimatedSize-Wrapper of [child].
  final bool animatedSize;

  const LoadingWidget(
      {Key? key,
      this.loading = true,
      this.sizeDuration = const Duration(milliseconds: 500),
      this.appearingDuration = const Duration(milliseconds: 500),
      this.loadingDuration = const Duration(milliseconds: 500),
      this.sizeCurve = Curves.linear,
      this.appearingCurve = Curves.fastOutSlowIn,
      this.loadingCurve = Curves.easeInOutCirc,
      this.padding = EdgeInsets.zero,
      this.animatedSize = true,
      required this.child})
      : super(key: key);
}

abstract class LoadingWidgetState<T extends StatefulWidget> extends State<T> {
  LoadingState _loadingState = LoadingState.LOADED;

  set loadingState(LoadingState value) {
    setLoadingState(value);
  }

  void setLoadingState(LoadingState value, {bool rebuild = true}) {
    _loadingState = value;
    if (rebuild && mounted) setState(() {});
  }

  LoadingState get loadingState => _loadingState;

  bool get disappearing => _loadingState == LoadingState.DISAPPEARING;

  bool get appearing => _loadingState == LoadingState.APPEARING;

  bool get loading => _loadingState == LoadingState.LOADING;

  bool get loaded => _loadingState == LoadingState.LOADED;
}
