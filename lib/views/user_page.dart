import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/components/list_menus.dart';
import 'package:cefcfco_app/components/list_menus_item.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/common/utils/common.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/shared_preferences.dart';
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;

class UserPage extends StatefulWidget {
  @override
  UserPageState createState() => new UserPageState();
}

class UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin{
  String _userName = '', _accessToken = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<ListMenusItem> menusList = [];

  final List list = [
    {
    'title': '账单',
    'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '输入相关',
    'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '统计',
    'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  },{
    'title': '账单',
    'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '输入相关',
    'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '统计',
    'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  },{
    'title': '账单',
    'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '输入相关',
    'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '统计',
    'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }];



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserName();

    for(var i=0;i<list.length;i++){
      ListMenusItem cellData =new ListMenusItem.fromJson(list[i]);
      menusList.add(cellData);
    }

  }

  _getUserName() async {
    SpUtil sp = await SpUtil.getInstance();
    setState(() {
      _userName = sp.getString(globals.userName);
      _accessToken = sp.getString(globals.accessToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        automaticallyImplyLeading: false,

        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '我的',
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
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: '设置',
            onPressed: ()=>{
            Application.router.navigateTo(
                context, routerConfig.setting,
                transition: TransitionType.fadeIn)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: new Container(
            decoration: new BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  decoration: new BoxDecoration(
                    color: Color(0xff1b82d2),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child:Container(
                          decoration: new BoxDecoration(
                              borderRadius:BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xff60a8e0),
                                width: 3.0,
                              )
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9.0),
                            child: new Image.asset('assets/img/user.jpg'),
                          ),
                        ),
                        flex: 2,
                      ),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children:<Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance,vertical: 6.0),
                                child: Text(_userName??'wu',
                                  textAlign:TextAlign.left,
                                  style: TextStyle(color: Colors.white,fontSize: 20.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance,vertical: 6.0),
                                child:Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6,vertical: 3.0),
                                  decoration: new BoxDecoration(
                                      color: Color(0xffa8ad5),
                                      borderRadius:BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xff4a9bdb),
                                        width: 1.0,
                                      )
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9.0),
                                    child: Text('华信期货：开发部',
                                      style: TextStyle(color: Color(0xffd4e8f7),fontSize: 12.0),),
                                  ),
                                ),
                              ),
                            ]
                        ),
                        flex: 8,
                      ),
                      Expanded(
                        child: Icon(Icons.chevron_right,color: Colors.white),
                        flex: 1,
                      ),
                    ],
                  ),
                ),
                ListMenus(menusList: menusList)
              ],
            )),
      ),

    );
  }
}


