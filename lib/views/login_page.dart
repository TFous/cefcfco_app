import 'package:cefcfco_app/components/ITextField.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/style/theme.dart' as Theme;
import 'package:cefcfco_app/services/user.dart';

import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();
  static String _userName='test123',_password='111111';

  ITextField _phoneCode = new ITextField(
    keyboardType: ITextInputType.text,
    hintText: 'Username',
    inputBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lightGreenAccent)),
    prefixIcon:Icon(Icons.person,color:Colors.white),
    hintStyle: TextStyle(color: Colors.white),
    textStyle: TextStyle(fontSize:18,color: Colors.white),
    fieldCallBack: (content) {
      _userName = content;
    },
  );
  ITextField _authCode = new ITextField(
    keyboardType: ITextInputType.password,
    hintText: 'Password',
    prefixIcon:Icon(Icons.lock,color:Colors.white),
    inputBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white)),
    hintStyle: TextStyle(color: Colors.white),
    textStyle: TextStyle(color: Colors.white),
    fieldCallBack: (content) {
      _password = content;
    },
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child:new  Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 55.0),
                child: new Image(
                    width: 170.0,
                    height: 170.0,
                    fit: BoxFit.fill,
                    image: new AssetImage('assets/img/login_logo.png')),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: _buildSignIn(context),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomPadding: false, // 键盘不遮挡
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
//     保持竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void loginFn() async {
    var token = await UserServices.userLogin(_userName,_password);
    if (token == 400) {
      showInSnackBar('账号或密码错误！');
    } else {
      var user = await UserServices.getUser(token);
      Application.router
          .navigateTo(context, '/home', transition: TransitionType.fadeIn);
      await SpUtil.getInstance()
        ..putString(globals.userName, user['username'])
        ..putString(globals.accessToken, token['access_token'])
        ..putBool(globals.isLogin, true);
//    设置 dio 的token
      await Request.setDio();
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.pinkAccent,
      duration: Duration(seconds: 3),
    ));
  }

  Future _submit() async {
    if (_userName.isNotEmpty&&_password.isNotEmpty) {
      loginFn();
    }else{
      showInSnackBar('账号或密码不能为空！');
    }
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: _phoneCode
                    ),
                    ListTile(
                        title: _authCode
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 170.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.Colors.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: Theme.Colors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientEnd,
                        Theme.Colors.loginGradientStart
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Theme.Colors.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "登录",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: _submit),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  "忘记密码?",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: "WorkSansMedium"),
                )),
          ),
        ],
      ),
    );
  }
}
