

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/store.dart';

class CardW extends ParseObject {
  static const String TABLE_NAME = "Card";
  static final String UID = "uID",
      OWNER = "owner",
      NUMBER = "number",
      FORMAT = "format",
      DESCRIPTION = "description",
      NOTES = "notes",
      INFO = "info";
  bool isDeleted = false;

  String toMyJson(){
    Map<String,dynamic> map = new Map<String, dynamic>();
    map[UID] = get(UID);
    if(this.containsKey(OWNER))
      map[OWNER] = get(OWNER);
    if(this.containsKey(NUMBER))
      map[NUMBER] = get(NUMBER);
    if(this.containsKey(FORMAT))
      map[FORMAT] = get(FORMAT);
    if(this.containsKey(DESCRIPTION))
      map[DESCRIPTION] = get(DESCRIPTION);
    if(this.containsKey(INFO))
      map[INFO] = (get(INFO) as ParseObject).get(keyVarObjectId);
    if(this.containsKey(keyVarObjectId))
      map[keyVarObjectId] = get(keyVarObjectId);
    map[keyVarAcl] = get(keyVarAcl);
    return jsonEncode(map);
  }
  static Future<CardW> fromMyJson(String json, CardInfoHolder ciHolder) async{
    final map = jsonDecode(json) as Map<String,dynamic>;
    final res = CardW(uid: map[UID]);
    if(map.containsKey(OWNER)) res.set(OWNER,map[OWNER]);
    if(map.containsKey(NUMBER)) res.set(NUMBER,map[NUMBER]);
    if(map.containsKey(FORMAT)) res.set(FORMAT,map[FORMAT]);
    if(map.containsKey(DESCRIPTION)) res.set(DESCRIPTION,map[DESCRIPTION]);
    if(map.containsKey(INFO)) res.set(INFO, await ciHolder.getCardInfoByObjectId(map[INFO]));
    if(map.containsKey(keyVarObjectId)) res.set(keyVarObjectId,map[keyVarObjectId]);
    if(map.containsKey(keyVarAcl)) res.set(keyVarAcl,map[keyVarAcl]);

    return res;
  }

  static Future<List<CardW>> fromMyJsonList(List<String> jsons, CardInfoHolder ciHolder) async{
    List<CardW> res = [];
    for(String json in jsons){
      res.add(await fromMyJson(json,ciHolder));
    }
    return res;
  }

  bool isEqual(CardW card){
    if(get(OWNER) != card.get(OWNER)) return false;
    if(get(NUMBER) != card.get(NUMBER))  return false;
    if(get(FORMAT) != card.get(FORMAT)) return false;
    if(get(DESCRIPTION) != card.get(DESCRIPTION)) return false;
    if(getInfo()?.get(keyVarObjectId) != card.getInfo()?.get(keyVarObjectId)) return false;
    //if(get(keyVarCreatedAt) != card.get(keyVarCreatedAt))  return false;
    //if(get(keyVarUpdatedAt) != card.get(keyVarUpdatedAt)) return false;
    if(get(keyVarObjectId) != card.get(keyVarObjectId)) return false;
    if(get(keyVarAcl) != card.get(keyVarAcl)) return false;
    return true;
  }
  static Future<CardW> fromParseObject(ParseObject object, BuildContext context) async{
    final card = CardW();
    final infoId = (object.get(INFO) as ParseObject).objectId;
    if(infoId == null){
      print("fromParseObject CardInfo objectId was null, parse interrupted.");
      return card;
    }
    final ci = await (context.read<CardInfoHolder>()).getCardInfoByObjectId(infoId);
    if(ci == null)
      return card;
    card.objectId = object.objectId;
    if(object.containsKey(INFO)) card.set(INFO, ci);
    if(object.containsKey(OWNER)) card.set(OWNER, object.get(OWNER));
    if(object.containsKey(NUMBER)) card.set(NUMBER,object.get(NUMBER));
    if(object.containsKey(UID)) card.set(UID,object.get(UID));
    if(object.containsKey(keyVarAcl)) card.setACL(object.getACL());
    //if(ci.containsKey(keyVarUpdatedAt)) card.set(keyVarUpdatedAt,object.get(keyVarUpdatedAt));
    //if(ci.containsKey(keyVarCreatedAt)) card.set(keyVarCreatedAt,object.get(keyVarCreatedAt));
    //if(ci.containsKey(INFO)) print((ci)?.get(keyVarObjectId).toString() ?? "CardInfo haven't objectId");
    return card;
  }
  static Future<List<CardW>> fromParseObjects(List<ParseObject> objects, BuildContext context) async{
    List<CardW> result = [];
    for(var i in objects){
      print("parsing object $i");
      result.add( await fromParseObject(i,context));
    }
    return result;
  }
  static Future<CardW?> createCard(CardW card) async{
    if(card.getInfo()?.objectId == null || card.getInfo()?.objectId == ""){
      CardInfo? newInfo = await CardInfo.createCardInfo(card.getInfo() as CardInfo);
      if(newInfo != null)
        card.setInfo(newInfo);
      else
        return null;
    }
    if(card.get(keyVarObjectId) != null && card.get(keyVarObjectId) != "") {
      print("createCard: card already created");
      return card;
    }
    ParseUser currentUser = (await ParseUser.currentUser() as ParseUser);
    ParseObject info = card.get(INFO);
    print("info.get(keyVarObjectId) == null: "+(info.get(keyVarObjectId) == null).toString());
    card.setACL(currentUser.getACL());
    card.set(CardW.OWNER, currentUser);
    ParseResponse resp = await card.create();
    if(resp.success){
      print("Card ${(resp.result as ParseObject).objectId} has been created.");
      card.set(keyVarObjectId,(resp.result as ParseObject).objectId);
      return card;
    }
    else {
      print("CardInfo creating is not success.");
      return null;
    }
  }

  int bgColor = 0;
  CardW({String? uid}) : super(TABLE_NAME){
    if(uid == null)
      uid = Uuid().v4();
    //setOwnerCurrentUser();
    //set<String>('objectId',uid);
    set<String>(UID,uid);
  }

  setOwnerCurrentUser() async{
    final user = await ParseUser.currentUser();
    set(OWNER, (user));
    setACL(ParseACL());
  }

  CardInfo? getInfo(){
    return get<CardInfo>(INFO);
  }
  void setInfo(CardInfo ci){
    set(INFO,ci);
  }

}

class CardHolder with ChangeNotifier{
  List<CardW> _data = [];
  CardInfoHolder? ciHolder = null;
  CardHolder(){
    //loadFromStorage();
  }

  void addOrUpdateCard(CardW card) async{
    bool inserted = false;
    for(int i = 0; i < _data.length; i++) {
      if(_data[i].get(CardW.UID)==card.get(CardW.UID)){
        if(!data[i].isEqual(card)){
          data[i] = card;
        }
        if((_data[i].getInfo() == null || (card.getInfo()!.isEqual(_data[i].getInfo()!))))
          ciHolder?.addOrUpdateCard(card.getInfo()!);
        inserted = true;
      }
    }
    if(card.objectId==null||card.objectId==""||card.getInfo() == null || card.getInfo()?.get(keyVarObjectId) == null)
      card = await CardW.createCard(card) ?? card;
    if(!inserted)
      _data.add(card);
    print("Card saving: ");
    card.save();
    notifyListeners();
    saveAllToStorage();
  }
  void addOrUpdateCards(List<CardW> cards) async{
    cards.map((e)=>addOrUpdateCard(e));
  }

  void _printObjectAcl(CardW card) async{
    String username = ((await ParseUser.currentUser()) as ParseUser).username ?? "null";
    print("card acl for username: " + username);
    print("card acl: " + (await card.getACL()).getReadAccess(userId:  username).toString());
  }

  void syncCardCloud(CardW card){
    print("sync card cloud");
    bool inserted = false;
    for(int i = 0; i < _data.length; i++) {
      print("${_data[i].get(CardW.UID)} == ${card.get(CardW.UID)} is ${(_data[i].get(CardW.UID)==card.get(CardW.UID)).toString()}");
      if(_data[i].get(CardW.UID)==card.get(CardW.UID)){
        if(!_data[i].isEqual(card)){
          //card = _data[i];
          data[i] = card;
          notifyListeners();
          print("sync card cloud listeners notified");
        }
        inserted = true;
      }
    }
    if(!inserted){
      data.add(card);
      notifyListeners();
      print("sync card cloud card added");
      saveAllToStorage();
    }

    //
    //saveAllToStorage();
    //

    card.save();
  }

  void synchronizeCardsWithCloud(List<CardW> cards, ParseUser? user){
    for (var c in cards){
      syncCardCloud(c);
    }
    /*
    if(data.length > cards.length && user != null) {
      final excludes = data.where((element) => !cards.contains(element));
      for(var e in excludes){
        if(e.getACL() == user.getACL())
          e.save();
        else{
          e.delete();
          data.remove(e);
        }
      }
    }*/
    print("sync data with cloud");
  }

  void saveAllToStorage() async{
    print("saveToPrefs");
    List<String> lst = _data.map<String>((e){
      return e.toMyJson();
    }).toList();
    print("save all to storage list ${lst.length}");
    print("first = " + (lst.length > 0 ? lst.first : "null"));
    (await SharedPreferences.getInstance()).setStringList(CardW.TABLE_NAME, lst);
  }

  Future<bool> loadFromStorage(CardInfoHolder ciHolder) async{
    final sp = await SharedPreferences.getInstance();
    //sp.setStringList(CardW.TABLE_NAME, []);
    final sl = sp.getStringList(CardW.TABLE_NAME);
    print("storage string list is null: ${sl==null}");
    if(sl!=null && sl.length > 0){
      final list = CardW.fromMyJsonList(sl,ciHolder);
      _data = await list;
      print("storage data len: ${data.length}");
      print("storage data first: ${sl.first}");
      return true;
    }
    print("load data from storage");
    return false;
  }

  List<CardW> get data => _data;

  set data(List<CardW> value) {
    _data = value;
    notifyListeners();
  }

}