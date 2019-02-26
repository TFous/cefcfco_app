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

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> with AutomaticKeepAliveClientMixin{
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Column(
      children: <Widget>[
      ],
    );
  }
}


