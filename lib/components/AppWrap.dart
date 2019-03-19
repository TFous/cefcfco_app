
import 'dart:async';

import 'package:cefcfco_app/net/Code.dart';
import 'package:cefcfco_app/net/HttpErrorEvent.dart';
import 'package:cefcfco_app/redux/AppState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppWrap extends StatefulWidget {
  final Widget child;

  AppWrap({Key key, this.child}) : super(key: key);

  @override
  State<AppWrap> createState() {
    return new _AppWrap();
  }
}

class _AppWrap extends State<AppWrap>{
  StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new StoreBuilder<AppStates>(builder: (context, store) {
      ///通过 StoreBuilder 和 Localizations 实现实时多语言切换
      return new Localizations.override(
        context: context,
        locale: store.state.locale,
        child: widget.child,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    stream =  Code.eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(stream != null) {
      stream.cancel();
      stream = null;
    }
  }

  errorHandleFunction(int code, message) {
    print(111111);
    Fluttertoast.showToast(msg: '我勒个去');
  }
}