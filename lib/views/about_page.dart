import 'dart:async';
import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/services/keyValue.dart';
import 'package:cefcfco_app/components/list_view_item.dart';
import 'package:cefcfco_app/components/list_refresh.dart' as listComp;
import 'package:cefcfco_app/views/first_page_item.dart';

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _user = '',_accessToken='';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print(222222222222);
    _getUserName();
  }
  _getUserName() async {
    SpUtil sp = await SpUtil.getInstance();
    setState(() {
      _user = sp.getString(globals.userName);
      _accessToken = sp.getString(globals.accessToken);
    });
  }
  headerView(){
    return
      Column(
        children: <Widget>[
          Stack(
            //alignment: const FractionalOffset(0.9, 0.1),//方法一
              children: <Widget>[
                Text('123'),
              ]),
          SizedBox(height: 1, child:Container(color: Theme.of(context).primaryColor)),
          SizedBox(height: 10),
        ],
      );

  }

  Widget makeCard(index, item) {
    var myTitle = '${item['displayName']}';
    var myUsername = '${'👲'}: ${item['keyName']} ';
    return new ListViewItem(
      itemTitle: myTitle,
      data: myUsername,
    );
  }

  Future getIndexListData([Map<String, dynamic> params]) async {
    var data = await keyValuesServices.getKeyValueList(_scaffoldKey);
    Map<String, dynamic> result = {
      "list": data['result'],
      'total': 20,
      'pageIndex': 0
    };
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff1b82d2),
        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '动态',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          color: Colors
              .white, //设置标题栏文字的颜色(new title的时候color不能为null不然会报错一般可以不用new title 直接new text,不过最终的文字里面还是以里面new text的style样式文字颜色为准)
        ),
//          centerTitle: true,//设置标题居中
        elevation: 0,
        //设置标题栏下面阴影的高度
//        brightness:Brightness.dark,//设置明暗模式（不过写了没看出变化，后面再看）
        primary: true,
        //是否设置内容避开状态栏
//        flexibleSpace: ,//伸缩控件后面再看
//        automaticallyImplyLeading: true,
        actions: <Widget>[
          //设置显示在右边的控件
          new Padding(
            child: new Icon(Icons.menu),
            padding: EdgeInsets.all(10.0),
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            //child: new List(),
              child:new listComp.ListRefresh(getIndexListData,makeCard,headerView)
          )
        ],
      ),
//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
