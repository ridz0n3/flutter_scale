import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_scale/model/measurement_line.dart';

typedef void ScaleChangedCallback(String scalePoints);

class KgSlider extends StatefulWidget{
  final int maxValue;
  final ScrollController weightKgController;
  final ScaleChangedCallback onChanged;
  KgSlider({this.maxValue, this.onChanged, this.weightKgController});

  @override
  _KgSliderState createState() => _KgSliderState();
}

class _KgSliderState extends State<KgSlider> with TickerProviderStateMixin{

  var scaleController = TextEditingController();
  FocusNode _focusNodes = FocusNode();

  double opacity = 1;
  double top = 3.0;
  double height = 20;
  double width = 40;
  double textSize = 10;
  InputBorder _inputBorder = InputBorder.none;

  bool isLeft = false;
  bool isRight = false;
  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    scaleController.text = '0';
    widget.weightKgController.addListener(_scaleScrollListener);
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
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          focusNode: _focusNodes,
                          controller: scaleController,
                          style: TextStyle(fontSize: textSize),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText: '0',
                              suffixText: 'kg',
                              border: _inputBorder
                          ),
                          onSubmitted: (val){

                            double moveToFeet = double.tryParse(val) ?? 0;
                            double moveToPixel = moveToFeet / 0.1 * 20;

                            if (widget.weightKgController.hasClients) {
                              widget.weightKgController.animateTo(moveToPixel, duration: Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
                            }

                            height = 20;
                            width = 40;
                            top = 3;
                            textSize = 10;
                            _inputBorder = InputBorder.none;
                            opacity = 1;
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
                          double moveToPixel = _getPixel();
                          if (isLeft) {
                            moveToPixel += 21;
                            widget.weightKgController.animateTo(moveToPixel, duration: Duration(
                                milliseconds: 100), curve: Curves.fastOutSlowIn);
                            isLeft = false;
                            setState(() {});
                          } else if (isRight) {
                            widget.weightKgController.animateTo(moveToPixel, duration: Duration(
                                milliseconds: 100), curve: Curves.fastOutSlowIn);
                            isRight = false;
                            setState(() {});
                          }
                        });
                      }
                      return true;
                    },
                    child: KgScaleWidget(
                      maxValue: widget.maxValue,
                      scaleController: widget.weightKgController,
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
                              top = 19;
                              textSize = 20;
                              opacity = 0;
                              _inputBorder = OutlineInputBorder();
                              Future.delayed(Duration(milliseconds: 500), (){
                                FocusScope.of(context).requestFocus(_focusNodes);
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
    var scalePoints = widget.weightKgController.offset.toInt();
    String scale = _kgScale(scalePoints);
    scaleController.text = scale;
    widget.onChanged(scale);
  }

  String _kgScale(int scalePoints){

    int gram = scalePoints ~/ 20;
    double kg = ((gram * 100) / 1000);

    getDirection();
    if(offset != kg){
      offset = kg;
      setState(() {});
    }

    return kg.toString();
  }

  double _getPixel(){
    double moveToFeet = double.tryParse('$offset') ?? 0;
    double moveToPixel = moveToFeet / 0.1 * 20;

    return moveToPixel;
  }

  void getDirection(){
    if(widget.weightKgController.position.userScrollDirection == ScrollDirection.forward){
      isRight = true;
      isLeft = false;
      setState(() {});
    }else if(widget.weightKgController.position.userScrollDirection == ScrollDirection.reverse){
      isLeft = true;
      isRight = false;
      setState(() {});
    }
  }
}

class KgScaleWidget extends StatefulWidget{

  final int maxValue;
  final ScrollController scaleController;

  const KgScaleWidget(
      {Key key,
        @required this.maxValue,
        @required this.scaleController,
      }) : assert(maxValue != null, "maxValue cannot be null. This is used to set scale limit. i.e maxValue=10"),
        assert(scaleController != null, "scaleController cannot be null. This is used to control the behaviour of scale like reading current scale point, move to particular point in scale etc. Try giving value like scaleController: ScrollController(initialScrollOffset: 0)"),
        super(key: key);

  @override
  _KgScaleWidgetState createState() => _KgScaleWidgetState();
}

class _KgScaleWidgetState extends State<KgScaleWidget> {

  List<MeasurementLine> measurementLineList = List<MeasurementLine>();
  int linesBetweenTwoPoints = 9;
  int middleLineAt = 5;

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
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5, top: 5),
      itemBuilder: (context, index) {
        final mLine = measurementLineList[index];

        if (mLine.type == Line.big) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 17,
              ),
              Container(
                height: 40,
                width: 3,
                color: Colors.black,
              ),
            ],
          );
        }
        else if (measurementLineList[index].type == Line.small) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 19,
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
                width: 18,
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