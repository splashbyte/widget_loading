# Widget Loading

<a href="https://pub.dev/packages/widget_loading"><img src="https://img.shields.io/pub/v/widget_loading.svg?style=flat?logo=dart" alt="pub.dev"></a>
<a href="https://github.com/SplashByte/widget_loading"><img src="https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd" alt="github"></a>
[![likes](https://badges.bar/widget_loading/likes)](https://pub.dev/packages/widget_loading/score)
[![pub points](https://badges.bar/widget_loading/pub%20points)](https://pub.dev/packages/widget_loading/score)
<a href="https://github.com/SplashByte/widget_loading/blob/main/LICENSE"><img src="https://img.shields.io/github/license/SplashByte/widget_loading.svg" alt="license"></a>

### If you like this package, please leave a like on pub.dev and star on GitHub.

A simple widget for loading widget contents.
It's an easy way to hide a widget when you have nothing to show and need a loading animation at the same time.

![example1](https://user-images.githubusercontent.com/43761463/109703122-66cd3480-7b95-11eb-9862-dfb45ed96b49.gif)
![example2](https://user-images.githubusercontent.com/43761463/109703129-69c82500-7b95-11eb-8496-2b933772c8c9.gif)

## Easy Usage

Easy to use and highly customizable.

### WiperLoading

```dart
WiperLoading(
  loading: loading,
  interval: interval,
  wiperDeformingFactor: deformingFactor,
  curve: curve,
  wiperBuilder: builder
  wiperWidth: wiperWidth,
  wiperColor: wiperColor,
  wiperBuilder: wiperBuilder,
  sizeCurve: sizeCurve,
  sizeDuration: sizeDuration,
  direction: wiperDirection,
  child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: yourChild,
  ),
  ...
)
```

or

```dart
WiperLoading.future(future: futureOfYourWidget, ...)
```

### CircularWidgetLoading

```dart
CircularWidgetLoading(
  loading: loading,
  child: yourChild,
  ...
)
```
