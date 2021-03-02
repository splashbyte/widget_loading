# Wiper Loading

A simple widget for loading widget contents.
It's an easy way to hide a widget when you have nothing to show and need a loading animation at the same time.

![example](https://user-images.githubusercontent.com/43761463/109582113-dbed2b00-7afd-11eb-8098-08418c2bd76b.gif)

## Easy Usage

### WiperLoading

```dart
WiperLoading(
  interval: interval,
  wiperDeformingFactor: deformingFactor,
  curve: curve,
  wiperBuilder: builder
  wiperWidth: wiperWidth,
  wiperColor: wiperColor,
  loading: loading,
  wiperBuilder: wiperBuilder,
  child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: yourChild,
  ),
)
```

or

```dart
WiperLoading.future(future: futureOfYourWidget)
```

### CircularLoading

```dart
CircularWidgetLoading(
  loading: loading,
  child: yourChild,
)
```
