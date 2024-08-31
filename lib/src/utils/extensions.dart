import 'dart:math';

import 'package:flutter/material.dart';

extension Derivation on CurvedAnimation {
  /// Returns the current speed/derivation of the Curve.
  ///
  /// Does not handle the case that [parent.value] is not between 0.0 and 1.0.
  double get speed {
    double dif = 0.01;
    switch (this.status) {
      case AnimationStatus.forward:
        double value = max(this.parent.value - dif, 0.0);
        if (value.closeTo(this.parent.value)) return 0.0;
        return (this.value - this.curve.transform(value)) /
            (this.parent.value - value);
      case AnimationStatus.reverse:
        double value = min(this.parent.value + dif, 1.0);
        if (value.closeTo(this.parent.value)) return 0.0;
        return (this.value - this.curve.transform(value)) /
            (value - this.parent.value);
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        break;
    }

    return 0.0;
  }
}

extension _XNumber on num {
  bool closeTo(num other, [num epsilon = 0.0001]) =>
      this > other - epsilon && this < other + epsilon;
}

extension Diagonal on Size {
  double get diagonal =>
      sqrt(this.width * this.width + this.height * this.height);
}
