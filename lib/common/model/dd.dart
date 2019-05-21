import 'package:flutter/cupertino.dart';

class TestNotification extends Notification {
  TestNotification({
    @required this.isFoucs,
  });

  final bool isFoucs;
}