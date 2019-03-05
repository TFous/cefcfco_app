import 'package:cefcfco_app/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void IIndexIsChangingCallBack(Function content);

class HomeBottomNavigationBar extends StatefulWidget {
  final List tabData;
  final TabController controller;
  final IIndexIsChangingCallBack indexIsChangingCallBack;

  HomeBottomNavigationBar(
      {Key key, this.tabData, this.controller, this.indexIsChangingCallBack})
      : assert(tabData.length > 0),
        super(key: key);

  @override
  HomeBottomNavigationBarState createState() {
    return new HomeBottomNavigationBarState();
  }
}

class HomeBottomNavigationBarState extends State<HomeBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  TabController controller;
  List<Widget> myTabs = [];
  List newTabData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setTabs(widget.tabData);
    controller = widget.controller;
    controller.addListener(() {
      if (controller.indexIsChanging) {
        setState(() {
          widget.indexIsChangingCallBack(setTabs);
        });
//        Application.router.navigateTo(
//            context, '${newTabData[controller.index]['router']}',
//            transition: TransitionType.fadeIn);
      }
    });
  }

  setTabs(tabData) {
    myTabs = [];
    newTabData = tabData;
    var tabDataLength = newTabData.length;
    for (int i = 0; i < tabDataLength; i++) {
      var node = newTabData[i];
      bool isShowBadge = node['isShowBadge'] ?? false;

      myTabs.add(new Tab(child: Builder(builder: (BuildContext context) {
        List<Widget> doms = [
          Column(
            children: <Widget>[
              node['icon'],
              Text(node['text']),
            ],
          )
        ];
        if (isShowBadge) {
          doms.add(Positioned(
              right: node['badgeData']['right'] ?? -5,
              top: node['badgeData']['top'] ?? -5,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: Text(node['badgeData']['num'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12.0)),
                ),
                decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              )));
        }
        return Stack(
          overflow: Overflow.visible,
          children: doms,
        );
      })));
    }
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

