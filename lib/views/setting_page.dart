import 'package:cefcfco_app/components/list_menus.dart';
import 'package:cefcfco_app/components/list_menus_item.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/common/utils/common.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/shared_preferences.dart';
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;
import 'package:cefcfco_app/services/setting.dart';

class SettingPage extends StatefulWidget {
  @override
  SettingPageState createState() => new SettingPageState();
}

class SettingPageState extends State<SettingPage> with AutomaticKeepAliveClientMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String oldSecondPassword = '';
  String newSecondPassword = '';
  List<ListMenusItem> menusList = [];
  List<ListMenusItem> menusList2 = [];
  final List list = [
    {
    'title': '修改密码',
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '新增二级密码',
    'icon': null,
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.page1,
        transition: TransitionType.fadeIn)
    },
  }, {
    'title': '修改二级密码',
    'icon': null,
    'onTapCallBack': (context) =>
    {
    Application.router.navigateTo(
        context,routerConfig.changeSecondPassword,
        transition: TransitionType.fadeIn)
    },
  }];

  final List list2 = [
    {
      'title': '切换主题',
      'icon': null,
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    },
    {
      'title': '消息设置',
      'icon': null,
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    },
    {
      'title': '自定义业务',
      'icon': null,
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    },
    {
      'title': '版本更新',
      'icon': null,
      'rightText': '版本号 1.0.58',
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    },
    {
      'title': '清楚缓存',
      'icon': null,
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    },
    {
      'title': '退出登录',
      'icon': null,
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.page1,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '关于我们',
      'icon': null,
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

    for(var i=0;i<list.length;i++){
      ListMenusItem cellData =new ListMenusItem.fromJson(list[i]);
      menusList.add(cellData);
    }
    for(var i=0;i<list2.length;i++){
      ListMenusItem cellData =new ListMenusItem.fromJson(list2[i]);
      menusList2.add(cellData);
    }
  }

  changeAndSetSecondPassword(){
    Map<String,String> secondPassword = {
      'oldSecondPassword': oldSecondPassword,
      'secondPassword': newSecondPassword
    };
    SettingServices.changeAndSetSecondPassword(secondPassword).then((result)=>{

    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),

        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '设置',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          color: Colors
              .white, //设置标题栏文字的颜色(new title的时候color不能为null不然会报错一般可以不用new title 直接new text,不过最终的文字里面还是以里面new text的style样式文字颜色为准)
        ),
        elevation: 0,
        primary: true,
      ),
      body: SingleChildScrollView(
        child: new Container(
            decoration: new BoxDecoration(
//              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                ListMenus(menusList: menusList),
                Container(
                  margin:const EdgeInsets.symmetric(vertical: 10.0),
                  color: const Color(0xFF00FF00),
                  child:ListMenus(menusList: menusList2) ,
                ),
              ],
            )),
      ),

    );
  }
}


