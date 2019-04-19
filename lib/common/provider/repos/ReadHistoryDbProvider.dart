import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cefcfco_app/common/provider/SqlProvider.dart';
import 'package:cefcfco_app/common/model/Repository.dart';
import 'package:cefcfco_app/common/config/Config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cefcfco_app/common/utils/CodeUtils.dart';

/**
 * 本地已读历史表
 * Created by guoshuyu
 * Date: 2018-08-07
 */
/// 如果是分钟图，则分别是 时间，
/// 当前分钟开盘价格，
/// 当前分钟收盘价格，
/// 当前分钟最高价格，
/// 当前分钟最低价格，
class ReadHistoryDbProvider extends BaseDbProvider {
  String name;
  final String columnId = "id";
  final String columnDateTime = "kLineDate";
  final String columnStartPrice = "startPrice";
  final String columnEndPrice = "endPrice";
  final String columnMaxPrice = "maxPrice";
  final String columnMinPrice = "minPrice";

  int id;
  String kLineDate;
  double startPrice;
  double endPrice;
  double maxPrice;
  double minPrice;

  int readDate;
  String data;

  ReadHistoryDbProvider(this.name);

  Map<String, dynamic> toMap(String kLineDate, double startPrice, double endPrice,double maxPrice,double minPrice) {
    Map<String, dynamic> map = {
      columnDateTime: kLineDate,
      columnStartPrice: startPrice,
      columnEndPrice: endPrice,
      columnMaxPrice: maxPrice,
      columnMinPrice: minPrice
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ReadHistoryDbProvider.fromMap(Map map) {
    id = map[columnId];
    kLineDate = map[columnDateTime];
    startPrice = map[columnStartPrice];
    endPrice = map[columnEndPrice];
    maxPrice = map[columnMaxPrice];
    minPrice = map[columnMinPrice];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnDateTime text not null,
        $columnMinPrice REAL not null,
        $columnMaxPrice REAL not null,
        $columnStartPrice REAL not null,
        $columnEndPrice REAL not null)
      ''';
  }

  @override
  tableName() {
    return name;
  }





  Future _getProvider(Database db, int page) async {
    List<Map<String, dynamic>> maps = await db.query(name,
        columns: [columnId, columnDateTime, columnStartPrice, columnEndPrice, columnMaxPrice, columnMinPrice],
        limit: Config.PAGE_SIZE,
        offset: (page - 1) * Config.PAGE_SIZE,
        orderBy: "$columnDateTime DESC");
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future _getProviderInsert(Database db, String kLineDate) async {
    List<Map<String, dynamic>> maps = await db.query(
      name,
      columns: [columnId, columnDateTime, columnStartPrice, columnEndPrice, columnMaxPrice, columnMinPrice],
      where: "$columnDateTime = ?",
      whereArgs: [kLineDate],
    );
    if (maps.length > 0) {
      ReadHistoryDbProvider provider = ReadHistoryDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  Future dropTable()async{
    Database db = await getDataBase();
    return await db.execute('drop table $name');
  }

  ///插入到数据库
  Future insert(String kLineDate, double startPrice, double endPrice,double maxPrice,double minPrice) async {
    Database db = await getDataBase();
    var provider = await _getProviderInsert(db, kLineDate);
    if (provider != null) {
      await db.delete(name, where: "$columnDateTime = ?", whereArgs: [kLineDate]);
    }
    return await db.insert(name, toMap(kLineDate, startPrice, endPrice, maxPrice, minPrice));
  }


  Future<List<Repository>> getAllData() async {
    Database db = await getDataBase();
    var provider = await db.rawQuery('SELECT * FROM $name ORDER BY $columnDateTime ASC' );
    if (provider != null) {
      List<Repository> list = new List();
      for (var providerMap in provider) {
        list.add(Repository.fromJson(providerMap));
      }
      return list;
    }
    return null;
  }


  Future<List<Repository>> getInitData(limit,offset) async {
    Database db = await getDataBase();
    var provider = await db.rawQuery('SELECT * FROM $name ORDER BY $columnDateTime ASC LIMIT $limit OFFSET $offset');
    if (provider != null) {
      List<Repository> list = new List();
      for (var providerMap in provider) {
        list.add(Repository.fromJson(providerMap));
      }
      return list;
    }
    return null;
  }



  Future<List<Repository>> getScaleDataByTime(time,limit) async {
    Database db = await getDataBase();
    List provider = [];
    List otherItem =[];
    int providerLength;
    provider = await db.rawQuery("select * from (SELECT * FROM $name WHERE $columnDateTime <= '$time' ORDER BY $columnDateTime desc LIMIT $limit) ORDER BY $columnDateTime ASC");
    providerLength =  provider.length;
    if(provider.length<limit){
      otherItem = await db.rawQuery("SELECT * FROM $name WHERE $columnDateTime > '$time' ORDER BY $columnDateTime ASC LIMIT ${limit-providerLength}");
    }
    if (provider != null) {
      List<Repository> list = new List();
      for (var providerMap in provider) {
        list.add(Repository.fromJson(providerMap));
      }
      for(var item in otherItem){
        list.add(Repository.fromJson(item));
      }

      return list;
    }
    return null;
  }



  Future<List<Repository>> getDataByTime(time,limit,{direction:'right'}) async {
    Database db = await getDataBase();
    var provider;
//    var _symbol = direction=='right'?'<':'>';
    if(direction=='right'){
      provider = await db.rawQuery("select * from (SELECT * FROM $name WHERE $columnDateTime < '$time' ORDER BY $columnDateTime desc LIMIT $limit) ORDER BY $columnDateTime ASC");

    }else{
      provider = await db.rawQuery("select * from (SELECT * FROM $name WHERE $columnDateTime > '$time' ORDER BY $columnDateTime ASC LIMIT $limit) ORDER BY $columnDateTime ASC");
    }
    if (provider != null) {
      List<Repository> list = new List();
      for (var providerMap in provider) {
        list.add(Repository.fromJson(providerMap));
      }
      return list;
    }
    return null;
  }


  ///获取事件数据
  Future<List<Repository>> geData(int page) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, page);
    if (provider != null) {
      List<Repository> list = new List();
      for (var providerMap in provider) {
        list.add(Repository.fromJson(providerMap));
      }
      return list;
    }
    return null;
  }
}
