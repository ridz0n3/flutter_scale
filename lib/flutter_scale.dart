library flutter_scale;

import 'package:flutter/material.dart';
import 'package:flutter_scale/model/measurement_line.dart';
import 'package:flutter_scale/slider_widget/main_slider.dart';

typedef void ScaleCallback(String scalePoints, String type);

class ScaleSlider extends StatelessWidget{

  final String type;
  final bool typeChange;
  final ScaleCallback onChanged;
  ScaleSlider({this.type, this.typeChange, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if(type == 'height'){
      return MainSlider(
        mainType: Type.cm,
        subType: Type.ft,
        typeChange: typeChange,
        onChanged: _sliderChange,
      );
    }else{
      return MainSlider(
        mainType: Type.kg,
        subType: Type.lb,
        typeChange: typeChange,
        onChanged: _sliderChange,
      );
    }
  }

  void _sliderChange(String value, String type){
    onChanged(value, type);
  }

}
