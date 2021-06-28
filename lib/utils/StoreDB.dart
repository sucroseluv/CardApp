
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/country.dart';
import 'package:wamc/layers/provider_layer.dart';
import '../data/store.dart';

class StoreDB {
  late Future<Database> database;
  late BuildContext context;
  StoreDB() {
    initDb();
  }

  void initDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("db started");
    String path = join(await getDatabasesPath(), 'db.db');
    print("path generated");
    final exists = databaseExists(path);
    if(await exists){
      print("Database was found\nStart opening.");
      database = openDatabase(path);
    }
    else{
      print("Database not found\nStart copy.");
      try{
        await Directory(dirname(path)).create(recursive: true);
      }catch(_){}

      ByteData data = await rootBundle.load(join("assets","db.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);

      final exists = databaseExists(path);
      if(await exists){
        print("Db exists now");
        database = openDatabase(path);
      }
      else{
        print("Db not exists yet");
      }
    }

    /*, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE [IF NOT EXISTS] regions ("
          "storeID INTEGER,"
          "region TEXT,"
          "isTop INTEGER"
          ");"
          "INSERT INTO regions(storeID,region,isTop) VALUES (2,'RU',0);"
          "INSERT INTO regions(storeID,region,isTop) VALUES (5,'RU',0);"
          );
    });*/

/*"_id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "logo TEXT,"
          "isDeleted INT"
          "homepage TEXT"*/
    print("db opened");
    sendTagsToProvider();
  }

  void sendStoresToProvider({BuildContext? newContext}) async{
    final db = await database;
    final context = newContext??this.context;
    String countries = context.read<CountryHolder>().getCountriesString();
    List<Map<String, Object?>>? storeIds = null;
    while(storeIds == null || (storeIds.length) < 0)
      storeIds = await db.query('regions',distinct: true,columns:['storeID'],where: 'region in ($countries)');
    print("sendStoresToProvider.length: ${storeIds.length}");
    if(storeIds.length==0){
      context.read<StoreHolder>().data = [];
      return;
    }
    String res = "";
    for (int i = 0; i < storeIds.length; i++) {
      res+="'${storeIds[i]['storeID']}',";
    }
    final ids = res.substring(0,res.length-1);
    final storeRes = await db.query('stores',where: '_id in ($ids)');
    final stores = List.generate(storeRes.length, (i) => Store(
        storeRes[i]['name'] as String,
        id:storeRes[i]['_id'] as int,
        logo:storeRes[i]['logo'] as String,
        isDeleted: storeRes[i]['isDeleted'] as int,
        homepage: storeRes[i]['homepage'] as String?)
    );
    context.read<StoreHolder>().data = stores;
  }

  void sendTagsToProvider({BuildContext? newContext}) async{
    final db = await database;
    final context = newContext??this.context;
    final storeIds = await db.query('tags');
    if(storeIds.length==0){
      return;
    }
    Map<int,List<String>> res = Map<int,List<String>>();
    for (int i = 0; i < storeIds.length; i++){
      if(res[storeIds[i]['storeID'] as int] == null)
        res[storeIds[i]['storeID'] as int] = [];
      res[storeIds[i]['storeID'] as int]!.add(storeIds[i]['tag'] as String);
    }
    context.read<TagsHolder>().data = res;
  }
  Future<Store?> getStoreByIdOrName({int? id, String? name}) async {
    if(id!=null && id==-1)
      return null;

    final db = await database;
    Future<List<Map<String, Object?>>>? storeResFuture;
    if(id != null) {
      storeResFuture = db.query('stores', where: '_id = ($id)');
    }
    else {
      storeResFuture = db.query('stores', where: 'name = ($name)');
    }
    final storeRes = await storeResFuture;
    if(storeRes.length == 0)
      return null;

    final stores = List.generate(storeRes.length, (i) => Store(
        storeRes[i]['name'] as String,
        id:storeRes[i]['_id'] as int,
        logo:storeRes[i]['logo'] as String,
        isDeleted: storeRes[i]['isDeleted'] as int,
        homepage: storeRes[i]['homepage'] as String?)
    );
    return stores.first;
  }
}