import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wamc/data/store.dart';

import 'card.dart';

class CardInfo extends ParseObject {
  static const String TABLE_NAME = "CardInfo";
  static final String  STORE_ID = "storeID",
      STORE_NAME = "storeName",
      IS_PUBLIC = "isPublic",
      REGION = "region",
      DISCOUNT = "discount";

  static Future<CardInfo?> createCardInfo(CardInfo info) async{
    if(info.get(keyVarObjectId) != null && info.get(keyVarObjectId) != "") {
      print("createCard: card already created");
      return info;
    }
    final resp = await info.create();
    if(resp.success){
      print("CardInfo ${(resp.result as ParseObject).objectId} has been created.");
      info.set(keyVarObjectId,(resp.result as ParseObject).objectId);
      return info;
    }
    else {
      print("CardInfo creating is not success.");
      return null;
    }
  }

  CardInfo(int? storeId, String? storeName) : super(TABLE_NAME){
    //objectId = Uuid().v4();
    if(storeId != null) set<int>(STORE_ID,storeId);
    if(storeName != null) set<String>(STORE_NAME, storeName);
    //set<bool>(IS_PUBLIC,true);
  }

  String toMyJson(){
    Map<String,dynamic> map = new Map<String, dynamic>();
    map[keyVarObjectId] = get(keyVarObjectId);
    if(this.containsKey(STORE_ID))
      map[STORE_ID] = get(STORE_ID);
    if(this.containsKey(STORE_NAME))
      map[STORE_NAME] = get(STORE_NAME);
    if(this.containsKey(IS_PUBLIC))
      map[IS_PUBLIC] = get(IS_PUBLIC);
    if(this.containsKey(REGION))
      map[REGION] = get(REGION);
    if(this.containsKey(DISCOUNT))
      map[DISCOUNT] = get(DISCOUNT);
    map[keyVarAcl] = getACL();
    return jsonEncode(map);
  }
  static CardInfo fromMyJson(String json){
    final map = jsonDecode(json) as Map<String,dynamic>;
    int? storeId = map.containsKey(STORE_ID) ? map[STORE_ID] : null;
    String? storeName = map.containsKey(STORE_NAME) ? map[STORE_NAME] : null;
    final res = CardInfo(storeId,storeName);
    if(map.containsKey(IS_PUBLIC)) res.set(IS_PUBLIC,map[IS_PUBLIC]);
    if(map.containsKey(REGION)) res.set(REGION,map[REGION]);
    if(map.containsKey(DISCOUNT)) res.set(DISCOUNT,map[DISCOUNT]);
    res.set(keyVarObjectId,map[keyVarObjectId]);
    res.set(keyVarAcl,map[keyVarAcl]);

    return res;
  }
  static List<CardInfo> fromMyJsonList(List<String> jsons){
    List<CardInfo> res = [];
    for(String json in jsons){
      res.add(fromMyJson(json));
    }
    return res;
  }

  bool isEqual(CardInfo card){
    if(get(STORE_ID) != card.get(STORE_ID)) return false;
    if(get(STORE_NAME) != card.get(STORE_NAME))  return false;
    if(get(IS_PUBLIC) != card.get(IS_PUBLIC)) return false;
    if(get(REGION) != card.get(REGION)) return false;
    if(get(DISCOUNT) != card.get(DISCOUNT)) return false;
    if(get(keyVarObjectId) != card.get(keyVarObjectId)) return false;
    //if(get(keyVarCreatedAt) != card.get(keyVarCreatedAt))  return false;
    //if(get(keyVarUpdatedAt) != card.get(keyVarUpdatedAt)) return false;
    if(get(keyVarAcl) != card.get(keyVarAcl)) return false;
    return true;
  }
}

class CardInfoHolder with ChangeNotifier{
  List<CardInfo> _data = [];
  CardInfoHolder(){
    //loadFromStorage();
  }

  void addOrUpdateCard(CardInfo card) async{
    bool inserted = false;
    for(int i = 0; i < _data.length; i++) {
      if(_data[i].get(keyVarObjectId)==card.get(keyVarObjectId)){
        _data[i] = card;
        inserted = true;
        return;
      }
    }
    if(card.objectId==null||card.objectId=="")
      card = await CardInfo.createCardInfo(card) ?? card;
    if(!inserted)
      _data.add(card);
    card.save();
    notifyListeners();
    saveAllToPrefs();
  }

  void setCardsInfoSafely(List<CardInfo> cards){
    for (CardInfo c in cards) {
      addOrUpdateCard(c);
    }
  }

  Future<CardInfo?> getCardInfoByObjectId(String objectId) async{
    CardInfo? result = null;
    try{result= _data.firstWhere((e) => e.objectId == objectId);}
    catch (e){ print("CardInfo is not in internal data"); }
    if(result == null){
      QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject(CardInfo.TABLE_NAME))
        ..whereEqualTo(keyVarObjectId, objectId);
      ParseResponse response = await query.query();
      if(response.success){
        if(response.results?.length == 0)
          return null;

        final pObject = (response.result as List<ParseObject>)[0];
        int? id = (pObject.get(CardInfo.STORE_ID) as int?);
        String? storeName = (pObject.get(CardInfo.STORE_NAME));
        final ci = CardInfo(id,storeName);
        if((pObject.get(CardInfo.IS_PUBLIC) != null))
          ci.set(CardInfo.IS_PUBLIC, (pObject.get(CardInfo.IS_PUBLIC) as bool));
        if((pObject.get(CardInfo.REGION) != null))
          ci.set(CardInfo.REGION, ((pObject.get(CardInfo.REGION))));
        if((pObject.get(CardInfo.DISCOUNT) != null))
          ci.set(CardInfo.DISCOUNT, ((pObject.get(CardInfo.DISCOUNT)) as int));
        ci.set(keyVarObjectId,(pObject.get(keyVarObjectId)));
        ci.set(keyVarAcl,(pObject.get(keyVarAcl)));
        data.add(ci);
        return ci;
      }
      else{
        print("CardInfo by ObjectId response is not success");
        return null;
      }
    }
    else
      return result;

  }

  void saveAllToPrefs() async{
    print("CardInfo saveToPrefs");
    List<String> lst = _data.map<String>((e){
      return e.toMyJson();
    }).toList();
    print("save all to storage list ${lst.length}");
    print("first = " + (lst.length > 0 ? lst.first : "null"));
    (await SharedPreferences.getInstance()).setStringList(CardInfo.TABLE_NAME, lst);
  }

  Future<bool> loadFromStorage() async{
    final sp = await SharedPreferences.getInstance();
    //sp.setStringList(CardW.TABLE_NAME, []);
    final sl = sp.getStringList(CardInfo.TABLE_NAME);
    print("storage string list is null: ${sl==null}");
    if(sl!=null && sl.length > 0){
      final list = CardInfo.fromMyJsonList(sl);
      data = list;
      print("storage data len: ${data.length}");
      print("storage data first: ${sl.first}");
      return true;
    }
    print("load data from storage");
    return false;
  }

  List<CardInfo> get data => _data;

  set data(List<CardInfo> value) {
    _data = value;
    notifyListeners();
  }

}

class PublicCardsHolder with ChangeNotifier{
  List<CardInfo> _data = [];

  PublicCardsHolder();

  List<CardInfo> get data => _data;

  set data(List<CardInfo> value) {
    _data = value;
    notifyListeners();
  }
}