import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/common/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/shared_preferences.dart';

class UserPage extends StatefulWidget {
  @override
  UserPageState createState() => new UserPageState();
}

class UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin{
  String _userName = '', _accessToken = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserName();
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
//        automaticallyImplyLeading: false,
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
          //设置显示在右边的控件
          new Padding(
            child: new Icon(Icons.settings),
            padding: EdgeInsets.all(10.0),
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
                                child: Text(_userName,
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
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                    border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text("账单"),
                    // item 标题
                    leading: Icon(Icons.assignment,color: Color(0xfff49c2e) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      showInSnackBar('2222',_scaffoldKey);
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                    border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text("输入相关"),
                    // item 标题
                    leading: Icon(Icons.keyboard,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                    border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assessment,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                      color: Colors.white,
                ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assistant_photo,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("输入相关"),
                    // item 标题
                    leading: Icon(Icons.keyboard,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assessment,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assistant_photo,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("输入相关"),
                    // item 标题
                    leading: Icon(Icons.keyboard,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assessment,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assistant_photo,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("输入相关"),
                    // item 标题
                    leading: Icon(Icons.keyboard,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assessment,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2)))
                  ),
                  child: ListTile(
                    title: Text("统计"),
                    // item 标题
                    leading: Icon(Icons.assistant_photo,color: Color(0xff108ee9) ,),
                    // item 前置图标
                    trailing: Icon(Icons.keyboard_arrow_right),
                    // item 后置图标
                    isThreeLine: false,
                    // item 是否三行显示
                    dense: true,
                    // item 直观感受是整体大小
                    contentPadding: EdgeInsets.all(3.0),
                    // item 内容内边距
                    enabled: true,
                    onTap: () {
                      print('点击:');
                    },
                    // item onTap 点击事件
                    onLongPress: () {
                      print('长按12312312:');
                    },
                    // item onLongPress 长按事件
                    selected: false, // item 是否选中状态
                  ),
                ),
              ],
            )),
      ),

    );
  }
}


