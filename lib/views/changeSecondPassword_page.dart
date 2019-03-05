import 'package:cefcfco_app/components/list_menus.dart';
import 'package:cefcfco_app/components/list_menus_item.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/utils/common.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/utils/router_config.dart' as routerConfig;
import 'package:cefcfco_app/services/setting.dart';

class ChangeSecondPasswordPage extends StatefulWidget {
  @override
  ChangeSecondPasswordPageState createState() => new ChangeSecondPasswordPageState();
}

class ChangeSecondPasswordPageState extends State<ChangeSecondPasswordPage> with AutomaticKeepAliveClientMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String oldSecondPassword = '';
  String newSecondPassword = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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
        backgroundColor: Color(0xff1b82d2),
        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '设置二级密码',
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

              ],
            )),
      ),

    );
  }
}


