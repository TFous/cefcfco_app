import 'package:cefcfco_app/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final List tabData;
  final num activeIndex;
  final Map msgTipInfo;
  final TabController controller;

  const HomeBottomNavigationBar({Key key, this.tabData, this.activeIndex, this.msgTipInfo, this.controller})
      : super(key: key);

  @override
  HomeBottomNavigationBarState createState() {
    return new HomeBottomNavigationBarState();
  }
}

class HomeBottomNavigationBarState extends State<HomeBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  TabController controller;
  List<Widget> myTabs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var tabDataLength = widget.tabData.length;
    controller = widget.controller;
    for (int i = 0; i < tabDataLength; i++) {
      bool isShowMsgInfo = widget.msgTipInfo!=null&&widget.msgTipInfo['index']==i?true:false;
      myTabs.add(new Tab(
          child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Column(
            children: <Widget>[
              widget.tabData[i]['icon'],
              Text(widget.tabData[i]['text']),
            ],
          ),
          isShowMsgInfo?Positioned(
              right: -5,
              top: -5,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: Text('12',
                      style: TextStyle(color: Colors.white, fontSize: 12.0)),
                ),
                decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              )):Text(''),
        ],
      )));
    }
    controller.addListener(() {
      if (controller.indexIsChanging) {
//        Application.router.navigateTo(
//            context, '${widget.tabData[controller.index]['router']}',
//            transition: TransitionType.fadeIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      color: const Color(0xFFF0EEEF), //底部导航栏主题颜色
      child: SafeArea(
        child: Container(
          height: 65.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFFd0d0d0),
                blurRadius: 3.0,
                spreadRadius: 2.0,
                offset: Offset(-1.0, -1.0),
              ),
            ],
          ),
          child: TabBar(
              controller: controller,
              indicatorColor: Theme.of(context).primaryColor,
              //tab标签的下划线颜色
              // labelColor: const Color(0xFF000000),
              indicatorWeight: 3.0,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: const Color(0xFF8E8E8E),
              tabs: myTabs),
        ),
      ),
    );
  }
}
