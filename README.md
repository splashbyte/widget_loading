# Wiper Loading

A simple widget for loading widget contents.
It's an easy way to hide a widget when you have nothing to show and need a loading animation at the same time.

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
