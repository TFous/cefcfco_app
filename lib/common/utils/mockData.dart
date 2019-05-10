library mockData;

import 'dart:math';

import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/model/MInLineModel.dart';

//* `lines`: K线图, 依次是: 时间(ms), 开盘价, 最高价, 最低价, 收盘价, 成交量


List creatItem(list,initPrice,dayMaxPrice,dayMinPrice,date,hour,minute){
  List item = [];
  var num1;
  if(list.isEmpty){
    num1 = initPrice;
  }else{
    num1 = list.last[2];
  }

  var num2 = getRandom(dayMaxPrice, dayMinPrice);
  var maxNum = num1 > num2 ? num1 : num2;
  var minNum = num1 > num2 ? num2 : num1;
  var a = maxNum + getRandom(1, 3);
  var b = minNum - getRandom(1, 3);

  var max = a > dayMaxPrice ? dayMaxPrice:a;
  var min = b < dayMinPrice ? dayMinPrice:b;
  item.add('$date $hour:$minute:59');
  item.add(num1);
  item.add(num2);
  item.add(max);
  item.add(min);
//  print('item-----$item');
  return item;
}
/// 如果是分钟图，则分别是 时间，
/// 当前分钟开盘价格，
/// 当前分钟收盘价格，
/// 当前分钟最高价格，
/// 当前分钟最低价格，
/// 55.19 ==> initPrice
/// 行情数据
/// "2019-04-08 09:31:00",
/// 

List<KLineModel> mockData(kLine){
  List<KLineModel> list = [];

  kLine.forEach((item) {
    var arr = item.split(',');
    Map<String, dynamic> providerMap = {
      "date":'${arr[0]}',
      "open":double.parse(arr[1]),
      "close":double.parse(arr[2]),
      "high":double.parse(arr[3]),
      "low":double.parse(arr[4]),
      "volume":double.parse(arr[5]),
      "amount":double.parse(arr[6]),
      "turn":arr[7]
    };

    list.add(KLineModel.fromJson(providerMap));
  });
  return list;
}


List<MInLineModel> mockMinData(kLine){
  List<MInLineModel> list = [];

  kLine.forEach((item) {
    Map<String, dynamic> providerMap = {
      "time":item[0],
      "price":item[1],
      "volume":item[2],
    };

    list.add(MInLineModel.fromJson(providerMap));
  });
  return list;
}


List mockKLineData(date, initPrice) {
  double dayMaxPrice = initPrice * 1.1;
  double dayMinPrice = initPrice * 0.9;

  List list = [];
  var minutes = [];
  var hours = ['09', 10, 11, 13, 14];

  for (var i = 0; i < 60; i++) {
    var minute = i.toString().length == 1 ? '0$i' : '$i';
    minutes.add(minute);
  }

  hours.forEach((hour) {
    if (hour == '09') {
      minutes.forEach((minute) {
        if (int.parse(minute) < 30) {
          return;
        }
        var item = creatItem(list,initPrice,dayMaxPrice,dayMinPrice,date,hour,minute);
        list.add(item);
      });
    } else if (hour == 11) {
      minutes.forEach((minute) {
        if (int.parse(minute) > 29) {
          return;
        }
        var item = creatItem(list,initPrice,dayMaxPrice,dayMinPrice,date,hour,minute);
        list.add(item);
      });
    } else {
      minutes.forEach((minute) {
        var item = creatItem(list,initPrice,dayMaxPrice,dayMinPrice,date,hour,minute);
        list.add(item);
      });
    }
  });
//  print(list);
  return list;
}

// 指定范围内小数后两位小数
double getRandom(max, min) {
  Random r = new Random();
  return (r.nextDouble() * (max - min + 0.01) + min);
}
