# Widget Loading

<a href="https://pub.dev/packages/widget_loading"><img src="https://img.shields.io/pub/v/widget_loading.svg?style=flat?logo=dart" alt="pub.dev"></a>
<a href="https://github.com/SplashByte/widget_loading"><img src="https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd" alt="github"></a>
<a href="https://pub.dev/packages/widget_loading/score"><img src="https://badges.bar/widget_loading/likes" alt="likes"></a>
<a href="https://github.com/SplashByte/widget_loading/raw/LICENSE"><img src="https://img.shields.io/github/license/SplashByte/widget_loading.svg" alt="license"></a>

A simple widget for loading widget contents.
It's an easy way to hide a widget when you have nothing to show and need a loading animation at the same time.

![example1](https://user-images.githubusercontent.com/43761463/109694771-76e01680-7b8b-11eb-832f-f3abb7883049.gif)
![example2](https://user-images.githubusercontent.com/43761463/109694781-7a739d80-7b8b-11eb-8384-8379a383059e.gif)

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

### CircularLoading

```dart
CircularWidgetLoading(
  loading: loading,
  child: yourChild,
  ...
)
```
