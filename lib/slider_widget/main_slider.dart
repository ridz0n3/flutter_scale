import 'package:flutter/cupertino.dart';
import 'package:flutter_scale/model/measurement_line.dart';
import 'package:flutter_scale/slider_widget/cm_slider.dart';
import 'package:flutter_scale/slider_widget/ft_slider.dart';
import 'package:flutter_scale/slider_widget/kg_slider.dart';
import 'package:flutter_scale/slider_widget/lb_slider.dart';


typedef void ScaleCallback(String scalePoints, String type);

class MainSlider extends StatefulWidget{

  final Type mainType;
  final Type subType;
  final bool typeChange;
  final ScaleCallback onChanged;
  MainSlider({this.mainType, this.subType, this.typeChange, this.onChanged});

  @override
  _MainSliderState createState() => _MainSliderState();
}

class _MainSliderState extends State<MainSlider> {

  ScrollController _weightKgController;
  ScrollController _weightLbController;
  ScrollController _heightCmController;
  ScrollController _heightFtController;

  String kgValue = '0';
  String lbValue = '0';
  String cmValue = '0';
  String ftValue = '0/0';

  @override
  void initState() {
    super.initState();
    _weightLbController = ScrollController(initialScrollOffset: 0);
    _weightKgController = ScrollController(initialScrollOffset: 0);
    _heightCmController = ScrollController(initialScrollOffset: 0);
    _heightFtController = ScrollController(initialScrollOffset: 0);

  }

  @override
  Widget build(BuildContext context) {
    if(widget.mainType == Type.kg){
      return Stack(
        children: <Widget>[
          Opacity(
            opacity: widget.typeChange ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.only(left:  widget.typeChange ? 0 : MediaQuery.of(context).size.width),
              child: LbSlider(
                maxValue: (204 * 2.205).floor(),
                weightLbController: _weightLbController,
                onChanged: _handleLbWeightScaleChanged,
              ),
            ),
          ),
          Opacity(
            opacity: widget.typeChange ? 0 : 1,
            child: Padding(
              padding: EdgeInsets.only(left: widget.typeChange ? MediaQuery.of(context).size.width : 0),
              child: KgSlider(
                maxValue: 204,
                weightKgController: _weightKgController,
                onChanged: _handleKgWeightScaleChanged,
              ),
            ),
          )
        ],
      );
    }else{

      return Stack(
        children: <Widget>[
          Opacity(
            opacity: widget.typeChange ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.only(left:  widget.typeChange ? 0 : MediaQuery.of(context).size.width),
              child: FtSlider(
                maxValue: 10,
                heightFtController: _heightFtController,
                onChanged: _handleFtHeightScaleChanged,
              ),
            ),
          ),
          Opacity(
            opacity: widget.typeChange ? 0 : 1,
            child: Padding(
              padding: EdgeInsets.only(left: widget.typeChange ? MediaQuery.of(context).size.width : 0),
              child: CmSlider(
                maxValue: (120 * 2.5).floor(),
                typeChange: widget.typeChange,
                heightCmController: _heightCmController,
                onChanged: _handleCmHeightScaleChanged,
              ),
            ),
          )
        ],
      );
    }
  }

  void _handleLbWeightScaleChanged(String scalePoints) {

    if(lbValue != scalePoints) {

      if(widget.typeChange) {
        double moveToKg = double.tryParse(scalePoints) ?? 0;
        double moveToLb = double.parse((moveToKg / 2.205).toStringAsFixed(1));
        double moveToPixel = moveToLb / 0.1 * 20;
        _weightKgController.animateTo(
            moveToPixel, duration: Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }else{
        widget.onChanged(kgValue, 'kg');
      }

      lbValue = scalePoints;

      setState(() {});

    }
  }

  void _handleKgWeightScaleChanged(String scalePoints) {

    if(kgValue != scalePoints) {

      if(!widget.typeChange) {
        double moveToKg = double.tryParse(scalePoints) ?? 0;
        double moveToLb = double.parse((moveToKg * 2.205).toStringAsFixed(1));
        double moveToPixel = moveToLb / 0.1 * 9;
        _weightLbController.animateTo(
            moveToPixel, duration: Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }else{
        widget.onChanged(lbValue, 'lb');
      }

      kgValue = scalePoints;

      setState(() {});

    }
  }

  void _handleFtHeightScaleChanged(String scalePoints) {

    if(ftValue != scalePoints){

      if(widget.typeChange){
        List pointList = scalePoints.split('/');
        double moveToCm = convertFeetToCm(pointList[0], pointList[1]);
        double moveToPixel = moveToCm / 0.1 * 1;
        _heightCmController.animateTo(
            moveToPixel, duration: Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }else{
        widget.onChanged(cmValue, 'cm');
      }

      ftValue = scalePoints;
      setState(() {});
    }

  }

  void _handleCmHeightScaleChanged(String scalePoints) {

    if(cmValue != scalePoints) {

      if(!widget.typeChange){
        double feet = convertCmToFeet(scalePoints);
        double inch = getInchBalance(scalePoints);

        double feetToInch = feet * 12;
        double inchToScalePoints = feetToInch * 25 + inch * 25;

        _heightFtController.animateTo(inchToScalePoints, duration: Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn);
      }else{
        widget.onChanged(ftValue, 'ft/in');
      }

      cmValue = scalePoints;
      setState(() {});
    }
  }

  double convertFeetToCm(height1, height2){
    var ftToIn = (double.parse(height1.replaceAll('-', '').replaceAll(',', '').replaceAll(' ', '')) * 30.48) + (double.parse(height2) * 2.54);
    return ftToIn;
  }

  double convertCmToFeet(height1){
    var cmToFt = double.parse(height1.replaceAll('-', '').replaceAll(',', '').replaceAll(' ', '')) / 30.48;
    return cmToFt.floorToDouble();
  }

  double getInchBalance(height1){
    var bal = (double.parse(height1.replaceAll('-', '').replaceAll(',', '').replaceAll(' ', '')) % 30.48) / 2.54;
    return bal.roundToDouble();
  }
}