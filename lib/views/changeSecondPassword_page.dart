import 'package:cefcfco_app/components/ITextField.dart';
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
import 'package:cefcfco_app/utils/common.dart' as common;


class ChangeSecondPasswordPage extends StatefulWidget {
  @override
  ChangeSecondPasswordPageState createState() =>
      new ChangeSecondPasswordPageState();
}

class ChangeSecondPasswordPageState extends State<ChangeSecondPasswordPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static String oldSecondPassword = '';
  static String newSecondPassword = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  changeAndSetSecondPassword() async{
    Map<String, String> secondPassword = {
      'oldSecondPassword': oldSecondPassword,
      'secondPassword': newSecondPassword
    };
    var result = await SettingServices.changeAndSetSecondPassword(secondPassword);
    if(result['success']==true){
//      common.showInSnackBar('修改成功', _scaffoldKey);
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('设置成功'),
                    RaisedButton(
                      child: Text('确定'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              )
          );
        },
      );
    }
  }

  ITextField _oldSecondPasswordInput = new ITextField(
    keyboardType: ITextInputType.password,
    hintText: '旧密码',
    inputBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.lightGreenAccent)),
    prefixIcon: Icon(Icons.lock, color: Colors.black),
    hintStyle: TextStyle(color: Colors.black12),
    textStyle: TextStyle(fontSize: 18, color: Colors.black),
    fieldCallBack: (content) {
      oldSecondPassword = content;
    },
  );
  ITextField _newSecondPasswordInput = new ITextField(
    keyboardType: ITextInputType.password,
    hintText: '新密码',
    inputBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.lightGreenAccent)),
    prefixIcon: Icon(Icons.lock, color: Colors.black),
    hintStyle: TextStyle(color: Colors.black12),
    textStyle: TextStyle(fontSize: 18, color: Colors.black),
    fieldCallBack: (content) {
      newSecondPassword = content;
    },
  );

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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(title: _oldSecondPasswordInput),
                ListTile(title: _newSecondPasswordInput),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: Padding(padding:EdgeInsets.symmetric(horizontal: globals.sidesDistance,vertical: 20.0), child: FlatButton(
                    onPressed: changeAndSetSecondPassword,
                    color: Colors.blueAccent,
                    //按钮的背景颜色
                    padding: EdgeInsets.symmetric(horizontal: 120.0),
                    //按钮距离里面内容的内边距
                    child: new Text('确定'),
                    textColor: Colors.white,
                    //文字的颜色
                    textTheme: ButtonTextTheme.primary,
                    //按钮的主题
                    onHighlightChanged: (bool b) { //水波纹高亮变化回调
                    },
                    disabledTextColor: Colors.black54,
                    //按钮禁用时候文字的颜色
                    disabledColor: Colors.black54,
                    //按钮被禁用的时候显示的颜色
                    highlightColor: Colors.blue,
                    //点击或者toch控件高亮的时候显示在控件上面，水波纹下面的颜色
                    splashColor: Colors.white,
                    //水波纹的颜色
                    colorBrightness: Brightness.light, //按钮主题高亮
//              shape:,//设置形状  LearnMaterial中有详解
                  ),),
                )

              ],
            )),
      ),

    );
  }
}


