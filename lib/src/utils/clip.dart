import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_loading/src/utils/extensions.dart';

class DotClipper extends CustomClipper<Rect> {
  final double factor;
  final double dotRadius;
  final double maxLoadingCircleSize;
  final double loadingCirclePadding;

  DotClipper(this.factor, this.dotRadius, this.maxLoadingCircleSize,
      this.loadingCirclePadding);

  @override
  Rect getClip(Size size) {
    double radius = min(maxLoadingCircleSize,
        min(size.width, size.height) - 2 * loadingCirclePadding) /
        2 -
        dotRadius;
    double x = size.width / 2;
    double y = size.height / 2;

    double maxAppearingRadius = sqrt(x * x + y * y);
    double appearingRadius =
        dotRadius + factor * (maxAppearingRadius - dotRadius);
    return Rect.fromCircle(
        center: Offset(x, y - radius), radius: appearingRadius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return this != oldClipper;
  }
}

class PathDotClipper extends CustomClipper<Path> {
  final double radiusFactor;

  PathDotClipper(this.radiusFactor);

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: radiusFactor * size.diagonal / 2))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return this != oldClipper;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InvertedDotClipper &&
              runtimeType == other.runtimeType &&
              radiusFactor == other.radiusFactor;

  @override
  int get hashCode => radiusFactor.hashCode;
}

class InvertedDotClipper extends CustomClipper<Path> {
  final double radiusFactor;

  InvertedDotClipper(this.radiusFactor);

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: radiusFactor * size.diagonal / 2))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return this != oldClipper;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InvertedDotClipper &&
              runtimeType == other.runtimeType &&
              radiusFactor == other.radiusFactor;

  @override
  int get hashCode => radiusFactor.hashCode;
}