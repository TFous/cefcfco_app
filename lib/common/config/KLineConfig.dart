

import 'package:flutter/material.dart';

class KLineConfig {
  static const HEIGHT_LIMIT = 0.03; // 上下限控件空余参数，最高最低价格多出的百分比


  static const TYPE_BOLL = 'type_boll'; // boll 图

  static const ARROW_WIDTH = 14; // 价格箭头长度
  static const ARROW_COLOR = Colors.black; // 箭头颜色


  static const EQUAL_PRICE_MARGIN = 2.0; // 等分线处价格边距
  static const EQUAL_PRICE_COLOR = Color(0xFF8e8e8e); // 等分线处价格颜色
  static const EQUAL_LINE_COLOR = Colors.black12; // 等分线颜色
  static const WRAP_BORDER_COLOR = Color(0xFF8e8e8e); // 最外层边框颜色


  static const MA5_COLOR = Color(0xFF131313); // 5日均线颜色
  static const MA10_COLOR = Color(0xFFee9d00 ); // 10日均线颜色
  static const MA15_COLOR = Color(0xFFfe576e); // 15日均线颜色
  static const MA20_COLOR = Color(0xFF65c43b); // 20日均线颜色



  static const CROSS_LINE_COLOR = Colors.black; // 十字线颜色
  static const CROSS_LINE_WIDTH = 1.4; // 十字线宽度
  static const CROSS_TEXT_COLOR = Colors.white; // 十字线指定价格颜色
  static const CROSS_TEXT_BG_COLOR = Color(0xFF6ba7f1); // 十字线指定价格颜色


  static const KLINE_UP_COLOR = Colors.red; // k线涨颜色
  static const KLINE_DOWN_COLOR = Colors.green; // k线跌颜色


  static const BOLL_MA_COLOR = Color(0xFF3badf5); // boll ma线颜色
  static const BOLL_UP_COLOR = Color(0xFFe93030); // boll up线颜色
  static const BOLL_DN_COLOR = Color(0xFF319b1c); // boll dn线颜色


  static const BLOCK_A_COLOR = Colors.greenAccent; // 区块 颜色
  static const BLOCK_B_COLOR = Colors.deepPurple; // 区块 颜色

}
