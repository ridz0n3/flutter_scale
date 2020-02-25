import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_scale/model/measurement_line.dart';

typedef void ScaleChangedCallback(String scalePoints);

class FtSlider extends StatefulWidget{
  final int maxValue;
  final ScrollController heightFtController;
  final ScaleChangedCallback onChanged;

  FtSlider({this.maxValue, this.heightFtController, this.onChanged});

  @override
  _FtSliderState createState() => _FtSliderState();
}

class _FtSliderState extends State<FtSlider> with TickerProviderStateMixin{

  var scaleFtController = TextEditingController();
  var scaleInController = TextEditingController();
  FocusNode _focusFtNodes = FocusNode();
  FocusNode _focusInNodes = FocusNode();

  double opacity = 1;
  double top = 3.0;
  double height = 20;
  double width = 40;
  double width2 = 20;
  double textSize = 10;
  InputBorder _inputBorder = InputBorder.none;

  bool isLeft = false;
  bool isRight = false;
  double offset = 0.0;
  String ftVal = '';

  @override
  void initState() {
    super.initState();
    scaleFtController.text = '0';
    scaleInController.text = '0';
    widget.heightFtController.addListener(_scaleScrollListener);
  }

  @override
  void dispose() {
    widget.heightFtController.removeListener(_scaleScrollListener);
    widget.heightFtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: AnimatedSize(
            vsync: this,
            duration: Duration(milliseconds: 400),
            child: Padding(
              padding: EdgeInsets.only(top: top, left: 19),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: width,
                        child: TextField(
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          focusNode: _focusFtNodes,
                          controller: scaleFtController,
                          style: TextStyle(fontSize: textSize),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: 'ft',
                            border: _inputBorder,
                          ),
                          onSubmitted: (value){
                            ftVal = value;
                            FocusScope.of(context).requestFocus(_focusInNodes);
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: width2,
                        child: TextField(
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          focusNode: _focusInNodes,
                          controller: scaleInController,
                          style: TextStyle(fontSize: textSize),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: 'in',
                            border: _inputBorder,
                          ),
                          onSubmitted: (inchVal){

                            double feet = double.tryParse(ftVal) ?? 0;
                            double inch = double.tryParse(inchVal) ?? 0;

                            double feetToInch = feet * 12;
                            double inchToScalePoints = feetToInch * 25 + inch * 25;

                            if (widget.heightFtController.hasClients) {
                              widget.heightFtController.animateTo(inchToScalePoints,
                                  duration: Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
                            }

                            height = 20;
                            width = 40;
                            width2 = 20;
                            top = 3;
                            textSize = 10;
                            opacity = 1;
                            _inputBorder = InputBorder.none;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),//textfield
        AnimatedOpacity(
          opacity: opacity,
          duration: Duration(milliseconds: 300),
          child: Container(
            height: 100,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification){
                      if (scrollNotification is ScrollEndNotification) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          double moveToPixel = offset;
                          if (isLeft) {
                            moveToPixel += 26;
                            widget.heightFtController.animateTo(moveToPixel, duration: Duration(
                                milliseconds: 100), curve: Curves.fastOutSlowIn);
                            isLeft = false;
                            setState(() {});
                          } else if (isRight) {
                            widget.heightFtController.animateTo(moveToPixel, duration: Duration(
                                milliseconds: 100), curve: Curves.fastOutSlowIn);
                            isRight = false;
                            setState(() {});
                          }
                        });
                      }
                      return true;
                    },
                    child: FtScaleWidget(
                      maxValue: widget.maxValue,
                      scaleController: widget.heightFtController,
                    ), //slider
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5 + 17 - 24, top: 5),
                  child: Container(
                      width: 51,
                      child: Stack(
                        alignment: AlignmentDirectional.topCenter,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 37.3),
                            child: Container(
                              color: Colors.black,
                              width: 3,
                              height: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 70.0),
                            child: Icon(
                              Icons.arrow_drop_up,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              height = 50;
                              width = 100;
                              width2 = 100;
                              top = 19;
                              textSize = 20;
                              opacity = 0;
                              _inputBorder = OutlineInputBorder();
                              Future.delayed(Duration(milliseconds: 500), (){
                                FocusScope.of(context).requestFocus(_focusFtNodes);
                              });
                              setState(() {});
                            },
                            child: Container(
                              width: 50,
                              height: 30,
                              color: Colors.red.withOpacity(0),
                            ),
                          ),
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
        ),//indicator
      ],
    );
  }

  void _scaleScrollListener(){
    var scalePoints = widget.heightFtController.offset.toInt();
    String scale = _ftScale(scalePoints);
    List ftList = scale.split('/');
    scaleFtController.text = ftList[0];
    scaleInController.text = ftList[1];
    widget.onChanged(scale);
  }

  String _ftScale(int scalePoints){
    int inchOffset = scalePoints ~/ 25;
    int feet = inchOffset ~/ 12;
    int inch = inchOffset % 12;

    getDirection();

    double ft = double.tryParse('$feet') ?? 0;
    double inchVal = double.tryParse('$inch') ?? 0;

    double feetToInch = ft * 12;
    double inchToScalePoints = feetToInch * 25 + inchVal * 25;

    if(offset != inchToScalePoints){
      offset = inchToScalePoints;
      setState(() {});
    }

    return '$feet/$inch';
  }

  void getDirection(){
    if(widget.heightFtController.position.userScrollDirection == ScrollDirection.forward){
      isRight = true;
      isLeft = false;
      setState(() {});
    }else if(widget.heightFtController.position.userScrollDirection == ScrollDirection.reverse){
      isLeft = true;
      isRight = false;
      setState(() {});
    }
  }
}

class FtScaleWidget extends StatefulWidget{

  final int maxValue;
  final ScrollController scaleController;

  const FtScaleWidget(
      {Key key,
        @required this.maxValue,
        @required this.scaleController,
      }) : assert(maxValue != null, "maxValue cannot be null. This is used to set scale limit. i.e maxValue=10"),
        assert(scaleController != null, "scaleController cannot be null. This is used to control the behaviour of scale like reading current scale point, move to particular point in scale etc. Try giving value like scaleController: ScrollController(initialScrollOffset: 0)"),
        super(key: key);

  @override
  _FtScaleWidgetState createState() => _FtScaleWidgetState();
}

class _FtScaleWidgetState extends State<FtScaleWidget> {

  List<MeasurementLine> measurementLineList = List<MeasurementLine>();
  int linesBetweenTwoPoints = 11;
  int middleLineAt = 6;

  @override
  void initState() {
    super.initState();
    _createListOfLinesToDraw();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: widget.scaleController,
      itemCount: measurementLineList.length,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5 - 5, top: 5),
      itemBuilder: (context, index) {
        final mLine = measurementLineList[index];

        if (mLine.type == Line.big) {
          return Stack(
            alignment: AlignmentDirectional.center,
            overflow: Overflow.visible,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 22,
                  ),
                  Container(
                    height: 40,
                    width: 3,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          );
        }
        else if (measurementLineList[index].type == Line.small) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 24,
              ),
              Container(
                height: 20,
                width: 1,
                color: Colors.grey,
              ),
            ],
          );
        }
        else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 23,
              ),
              Container(
                height: 30,
                width: 2,
                color: Colors.black,
              ),
            ],
          );
        }

      },
    );
  }

  void _createListOfLinesToDraw(){
    for (int i = 0; i <= widget.maxValue; i++) {
      measurementLineList.add(MeasurementLine(type: Line.big, value: '$i'));
      for (int j = 1; j <= linesBetweenTwoPoints; j++) {
        measurementLineList.add(
            j != middleLineAt ?
            MeasurementLine(type: Line.small, value: '$i.$j') :
            MeasurementLine(type: Line.medium, value: '$i.$j')
        );
      }
    }
  }
}