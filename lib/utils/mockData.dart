library mockData;

import 'dart:math';

//* `lines`: K线图, 依次是: 时间(ms), 开盘价, 最高价, 最低价, 收盘价, 成交量
List kLine = [
  [
    "2019-04-08 09:30:00",
    60.71,
    59.71,
    60.71,
    55.19,
  ],
];

List mockDatas(num, max, min) {
  List list = [];
  for (var i = 0; i < num; i++) {
    List item = [];
    item.add("2019-04-08 09:30:00");
    var num1 = getRandom(max, min);
    var num2 = getRandom(max, min);
    item.add(num1);
    item.add(num2);
    item.add(num1*1.1);
    item.add(num2*1.1);
    list.add(item);
  }
  return list;
}

// 指定范围内小数后两位小数
double getRandom(max, min) {
  Random r = new Random();
  return (r.nextDouble() * (max - min + 0.01) + min);
}
