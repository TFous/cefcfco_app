import 'dart:math';

import 'package:cefcfco_app/common/provider/repos/ReadHistoryDbProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/CustomView/MyCustomCircle.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;

class GridAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GridAnimationState();
  }
}

class GridAnimationState extends State<GridAnimation> {

  List<String> lists = [
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557760&di=2c0ccc64ab23eb9baa5f6582e0e4f52d&imgtype=0&src=http%3A%2F%2Fpic.feizl.com%2Fupload%2Fallimg%2F170725%2F43998m3qcnyxwxck.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557760&di=37d5107e6f7277bc4bfd323845a2ef32&imgtype=0&src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Fsmccloud%2Ffetch%2F2015%2F06%2F05%2F79697840747611479.JPEG",
];

  void showPhoto(BuildContext context, f, index) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('图片${index + 1}')),
        body: SizedBox.expand(
          child: Hero(
            tag: index,
            child: new Photo(url: f),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('GridAnimation'),
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new SafeArea(
                top: false,
                bottom: false,
                child: new GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 4.0,
                  padding: const EdgeInsets.all(4.0),
                  childAspectRatio: 1.5,
                  children: lists.map((f) {
                    return new GestureDetector(
                      onTap: () {
                        var index;
                        if (lists.contains(f)) {
                          index = lists.indexOf(f);
                        }
                        showPhoto(context, f, index);
                      },
                      child: Image.network(
                        f,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ));
  }
}

class Photo extends StatefulWidget {
  const Photo({Key key, this.url}) : super(key: key);
  final url;

  @override
  State<StatefulWidget> createState() {
    return PhotoState();
  }
}

class PhotoState extends State<Photo> with SingleTickerProviderStateMixin {
  int subscript = 0;
  int index = 0;
  double onHorizontalDragDistance;
  double initPrice = 55.19;
  double kLineWidth = 8;
  double kLineMargin = 2;
  double canvasWidth;  /// 画布长度，用于计算渲染数据条数
  double sideWidth = 48.0;
  int maxKlinNum; /// 当前klin最大容量个数
  double dragDistance = 8.0; /// 滑动距离，用于判断多长距离请求一次
  ReadHistoryDbProvider provider = new ReadHistoryDbProvider();

  List mockDatas =[];
//  List mockDatas = mockData.mockDatas(100, 60.71, 49.67);
  var historyData;
  //数据源
  List showKLineData = [];


  AnimationController _controller;
  Animation<Offset> _animation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  double _kMinFlingVelocity = 600.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    mockDatas = mockData.mockKLineData('2019-04-10', initPrice);

//    dropTable();
//    mockDatas.forEach((item) async {
//      await inserData(item);
//    });


    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });
  }

  dropTable()async{
    ReadHistoryDbProvider provider = new ReadHistoryDbProvider();
    await provider.dropTable();
    print('删除成功');
  }

  getAllData()async{
    ReadHistoryDbProvider provider = new ReadHistoryDbProvider();
    return await provider.getAllData();
  }

  getLimitData(limit,offset)async{
    return await provider.getInitData(limit,offset);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    // widget的屏幕宽度
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    // 限制他的最小尺寸
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // 计算图片放大后的位置
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
      // 限制放大倍数 1~3倍
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
      // 更新当前位置
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    // 计算当前的方向
    final double distance = (Offset.zero & context.size).shortestSide;
    // 计算放大倍速，并相应的放大宽和高，比如原来是600*480的图片，放大后倍数为1.25倍时，宽和高是同时变化的
    _animation = _controller.drive(Tween<Offset>(
        begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  void _handleOnHorizontalDragStart(details){
    print('_handleOnHorizontalDragStart $details');
    onHorizontalDragDistance = 0;
  }
  /// 获取初始化 画布数据
  initCanvasData(width) async{
    var kLineDistance = kLineWidth+kLineMargin;
    var minLeve = width~/kLineDistance;
    var datas = await provider.getAllData();
    var length= datas.length;
    print('length-------$length');
//    List subList = mockDatas.sublist(length-minLeve);
    List subList = await getLimitData(minLeve,length-minLeve);
    print('last item ===> ${subList[minLeve-1]}');
    setState(() {
      canvasWidth = width;
      maxKlinNum = minLeve;
      showKLineData = subList;
    });
  }




  Future _handleOnHorizontalDragUpdate(details) async {
//    print('_handleOnHorizontalDragUpdate ${details.delta.dx}');

    onHorizontalDragDistance += details.delta.dx;

    if(details.delta.dx < 0){  /// 向<----滑动，历史数据
//      print('<------  ${details.delta.dx}');
//      print('<------onHorizontalDragDistance  $onHorizontalDragDistance');
//      print('<------  ${(onHorizontalDragDistance/dragDistance).abs()}');

      if((onHorizontalDragDistance/dragDistance).abs()>1){
        onHorizontalDragDistance += dragDistance;

        /// 如果是最后时间则没有数据
        if(showKLineData.last.kLineDate.split(' ')[1] == "14:59:59"){
          return;
        }

        var time = showKLineData.first.kLineDate;
        var newList = await provider.getDataByTime(time,maxKlinNum,direction:'left');
        setState(() {
          showKLineData = newList;
        });
      }

//      print('向左滑动');
    }else{  /// 向--->滑动，最新数据
      print('firsttime-------${showKLineData.first.kLineDate}');
      if(showKLineData.first.kLineDate.split(' ')[1] == "09:30:59"){
        return;
      }
      if((onHorizontalDragDistance/dragDistance).abs()>1){
        onHorizontalDragDistance -= dragDistance;
        var time = showKLineData[showKLineData.length-1].kLineDate;
        var newList = await provider.getDataByTime(time,maxKlinNum,direction:'right');
        setState(() {
          showKLineData = newList;
        });
      }
    }
  }






  static inserData(item)async{
    ReadHistoryDbProvider provider = new ReadHistoryDbProvider();
    return provider.insert(item[0],item[1],item[2],item[3],item[4]);
  }


  void _handleOnHorizontalDragEnd(details)async{
    onHorizontalDragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - sideWidth;
    if(canvasWidth != width){
      initCanvasData(width);
    }

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(vertical: globals.sidesDistance),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onScaleStart: _handleOnScaleStart,
                    onScaleUpdate: _handleOnScaleUpdate,
                    onScaleEnd: _handleOnScaleEnd,
                    onHorizontalDragStart:_handleOnHorizontalDragStart,
                    onHorizontalDragUpdate:_handleOnHorizontalDragUpdate,
                    onHorizontalDragEnd:_handleOnHorizontalDragEnd,
                    child: ClipRect(
                      child: Transform(
                          transform: Matrix4.identity()
                            ..translate(_offset.dx, _offset.dy)
                            ..scale(_scale),
                          child:new MyCustomCircle(showKLineData,initPrice,kLineWidth,kLineMargin)
                      ),
                      // child: Image.network(widget.url,fit: BoxFit.cover,),
                    ),
                  ),
                ),
                Container(
                  /// 此组件在主轴方向占据48.0逻辑像素
                  width: sideWidth,
                  height: 200,
                  color: Colors.green,
                  child: Text('33333'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
