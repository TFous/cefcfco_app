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

class FirstPage extends StatefulWidget {
  @override
  FirstPageState createState() => new FirstPageState();
}

class FirstPageState extends State<FirstPage> with AutomaticKeepAliveClientMixin{
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();
  String _user = '',_accessToken='';
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

  Widget makeCard(index,item){
    var myTitle = '${item.title}';
    var myUsername = '${'👲'}: ${item.username} ';
    return new ListViewItem(itemTitle: myTitle,data: myUsername,);
  }

  Future<Map> getIndexListData([Map<String, dynamic> params]) async {
    const juejin_flutter = 'https://timeline-merger-ms.juejin.im/v1/get_tag_entry?src=web&tagId=5a96291f6fb9a0535b535438';
    var pageIndex = (params is Map) ? params['pageIndex'] : 0;
    final _param  = {'page':pageIndex,'pageSize':20,'sort':'rankIndex'};
    var responseList = [];
    var  pageTotal = 0;

    try{
      var response = await Request.get(juejin_flutter,_param);
      responseList = response['d']['entrylist'];
      pageTotal = response['d']['total'];
      if (!(pageTotal is int) || pageTotal <= 0) {
        pageTotal = 0;
      }
    }catch(e){

    }
    pageIndex += 1;
    List resultList = new List();
    for (int i = 0; i < responseList.length; i++) {
      try {
        FirstPageItem cellData = new FirstPageItem.fromJson(responseList[i]);
        resultList.add(cellData);
      } catch (e) {
        // No specified type, handles all
      }
    }
    Map<String, dynamic> result = {"list":resultList, 'total':pageTotal, 'pageIndex':pageIndex};
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Column(
      children: <Widget>[
        new Expanded(
          //child: new List(),
            child: listComp.ListRefresh(getIndexListData,makeCard,headerView)
        )
      ],
    );
  }
}


