import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/shared_preferences.dart';

import 'package:cefcfco_app/components/list_view_item.dart';
import 'package:cefcfco_app/components/list_refresh.dart' as listComp;
import 'package:cefcfco_app/views/first_page_item.dart';
import 'package:cefcfco_app/services/keyValue.dart';
import 'package:cefcfco_app/style/theme.dart' as Theme;

class UserPage extends StatefulWidget {
  @override
  UserPageState createState() => new UserPageState();
}

headerView(){
  return
    Column(
      children: <Widget>[

      ],
    );

}

Widget makeCard(index,item){
  var myTitle = '${item['displayName']}';
  var myUsername = '${'👲'}: ${item['keyName']} ';
  return new ListViewItem(itemTitle: myTitle,data: myUsername,);
}

Future<Map> getIndexListData([Map<String, dynamic> params]) async {
  var dd = await keyValuesServices.getKeyValueList();
  Map<String, dynamic> result = {"list":dd['result'], 'total':20, 'pageIndex':0};
  return result;
}
class UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin{
  var _keyValueList = {} ;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _getList();
  }
  _getList() async {
    var data = await keyValuesServices.getKeyValueList();
  }
  _submit(){
    getIndexListData();
    _getList();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Column(
      children: <Widget>[
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
        new Expanded(
          //child: new List(),
            child: listComp.ListRefresh(getIndexListData,makeCard,headerView)
        )
      ],
    );
  }
}


