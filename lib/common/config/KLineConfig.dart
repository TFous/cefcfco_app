

import 'package:flutter/material.dart';

class KLineConfig {
  static const HEIGHT_LIMIT = 0.03; // 上下限控件空余参数，最高最低价格多出的百分比


  static const TYPE_BOLL = 'type_boll'; // boll 图

  static const ARROW_WIDTH = 14; // 价格箭头长度
  static const ARROW_COLOR = Colors.black; // 箭头颜色


  static const EQUAL_PRICE_COLOR = Colors.black; // 等分线处价格颜色
  static const EQUAL_LINE_COLOR = Colors.black12; // 等分线颜色
  static const WRAP_BORDER_COLOR = Colors.black; // 最外层边框颜色


  static const MA5_COLOR = Colors.greenAccent; // 5日均线颜色
  static const MA10_COLOR = Colors.deepPurple; // 10日均线颜色
  static const MA15_COLOR = Colors.brown; // 15日均线颜色
  static const MA20_COLOR = Colors.cyanAccent; // 20日均线颜色



  static const CROSS_LINE_COLOR = Colors.blueAccent; // 十字线颜色
  static const CROSS_LINE_WIDTH = 1.4; // 十字线宽度
  static const CROSS_TEXT_COLOR = Colors.white; // 十字线指定价格颜色


  static const KLINE_UP_COLOR = Colors.red; // k线涨颜色
  static const KLINE_DOWN_COLOR = Colors.green; // k线跌颜色


  static const BOLL_MA_COLOR = Colors.cyanAccent; // boll ma线颜色
  static const BOLL_UP_COLOR = Colors.redAccent; // boll up线颜色
  static const BOLL_DN_COLOR = Colors.brown; // boll dn线颜色


  static const BLOCK_A_COLOR = Colors.greenAccent; // 区块 颜色
  static const BLOCK_B_COLOR = Colors.deepPurple; // 区块 颜色

}
