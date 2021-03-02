import 'package:widget_loading/src/utils/loading_state.dart';

abstract class LoadingWidget {
  LoadingState _loadingState;

  set loadingState(LoadingState value) {
    _loadingState = value;
  }

  bool get disappearing => _loadingState == LoadingState.DISAPPEARING;

  bool get appearing => _loadingState == LoadingState.APPEARING;

  bool get loading => _loadingState == LoadingState.LOADING;

  bool get loaded => _loadingState == LoadingState.LOADED;
}