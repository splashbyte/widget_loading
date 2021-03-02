import 'dart:math';
import 'package:flutter/animation.dart';

extension Derivation on CurvedAnimation{
  double get speed{
    double dif = 0.01;
    switch (this.status){
      case AnimationStatus.dismissed:
        return 0.0;
      case AnimationStatus.forward:
        double value = max(this.parent.value - dif, 0.0);
        if(value == this.parent.value) return 0.0;
        return (this.value - this.curve.transformInternal(value))/(this.parent.value-value);
      case AnimationStatus.reverse:
        double value = min(this.parent.value + dif, 1.0);
        if(value == this.parent.value) return 0.0;
        return (this.value - this.curve.transformInternal(value))/(value-this.parent.value);
        break;
      case AnimationStatus.completed:
        return 0.0;
        break;
    }
  }
}