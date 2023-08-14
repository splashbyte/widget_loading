# Widget Loading

[![pub.dev](https://img.shields.io/pub/v/widget_loading.svg?style=flat?logo=dart)](https://pub.dev/packages/widget_loading)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/SplashByte/widget_loading)
[![likes](https://img.shields.io/pub/likes/widget_loading)](https://pub.dev/packages/widget_loading/score)
[![popularity](https://img.shields.io/pub/popularity/widget_loading)](https://pub.dev/packages/widget_loading/score)
[![pub points](https://img.shields.io/pub/points/widget_loading)](https://pub.dev/packages/widget_loading/score)
[![license](https://img.shields.io/github/license/SplashByte/widget_loading.svg)](https://github.com/SplashByte/widget_loading/blob/main/LICENSE)

[![buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20pizza&emoji=🍕&slug=splashbyte&button_colour=FF8838&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=ffffff')](https://www.buymeacoffee.com/splashbyte)

### If you like this package, please leave a like there on [pub.dev](https://pub.dev/packages/widget_loading) and star on [GitHub](https://github.com/SplashByte/widget_loading).

Simple widgets for loading widget contents.
It's an easy way to hide a widget when you have nothing to show and need a loading animation at the same time.

[![example1](https://user-images.githubusercontent.com/43761463/109703122-66cd3480-7b95-11eb-9862-dfb45ed96b49.gif)](https://splashbyte.dev/flutter_examples/widget_loading/index.html)
[![example2](https://user-images.githubusercontent.com/43761463/109703129-69c82500-7b95-11eb-8496-2b933772c8c9.gif)](https://splashbyte.dev/flutter_examples/widget_loading/index.html)

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
