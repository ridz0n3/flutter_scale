import 'package:flutter/material.dart';

class MeasurementLine {
  String value;
  Line type;

  MeasurementLine({this.value, @required this.type});
}

enum Line {
  big,
  medium,
  small,
}

enum Type {
  cm,
  ft,
  kg,
  lb
}