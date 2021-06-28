
import 'dart:convert';

import 'package:flutter/cupertino.dart';
//import 'package:flutter_parse/flutter_parse.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:path/path.dart';

class ParseManager {
  void parseIsBullshit (BuildContext context) async {
    print("parse object creating..");
    ParseUser currentUser = (await ParseUser.currentUser() as ParseUser);
    var info = ParseObject('CardInfo')
        ..set(CardInfo.IS_PUBLIC,true)
        ..set(CardInfo.REGION,"RU")
        ..set(CardInfo.STORE_ID,2)
        //..set(CardInfo.STORE_NAME,"Incity")
        ..setACL(currentUser.getACL());
    final infoResp = (await info.save());
    print("info save response success: " + infoResp.success.toString());
    if(infoResp.success){
      String cardId = (infoResp.result as ParseObject)['objectId'];
      print("Card id:" + cardId);
      info.set(keyVarObjectId, cardId.toString());
      String uid = Uuid().v4();
      var obj = ParseObject('Card')
        ..set(keyVarObjectId,uid)
        ..set(CardW.OWNER,currentUser)
        ..set(CardW.NUMBER,"12345678")
        ..set(CardW.UID, uid)
        ..set(CardW.INFO, info)
        ..setACL(currentUser.getACL());
      print("parse object created");
      final response = await obj.create();
      print("response success:" + response.success.toString());
      if (response.success) {
        String obj = (response.result as ParseObject)['objectId'];
        print(obj);
      }
    }

  }


  final String APP_ID = "TNPl4cW3iOp2utgBf5n7tCQ9r05w7bQpGjwGd9of",
    SERVER_ID = "http://db.wherearemycards.com:1337/parse/";

    static final String CREATE_AT = "createAt",
      IS_ANONYMOUS = "isAnonymous",
      EMAIL = "email", PASSWORD = "password";

    static final String CARDS = "cards", DELETED_CARDS = "deletedCards";

    static final String
    CREATE_ANONYMOUS_USER = "createAnonymousUser",
      LOG_IN_AND_MERGE = "logInAndMerge",
      LOG_IN_VIA_FACEBOOK = "logInViaFacebook",
      LOG_IN_VIA_TWITTER = "logInViaTwitter",
      LOG_IN_VIA_GOOGLE = "logInViaGoogle",
      LOG_IN_VIA_VK = "logInViaVK";

    static final String SESSION_TOKEN = "sessionToken",
      SESSION_SECRET = "sessionSecret",
      MERGE = "merge";

    static final String GET_PUBLIC_CARD = "getPublicCard",
      GET_CARD_LINK = "getCardLink",
      GET_SHARED_CARD = "getSharedCard",
      DELETE_CARDS = "deleteCards",
      GET_FREE_CARDS_COUNT = "getFreeCardsCount",
      CREATE_TRANSACTION = "createTransaction";

    static final String CARD = "card",
      TRANSACTION = "transaction",
      LINK = "link";

    static final String PURCHASE_DATA = "purchaseData", SIGNED_DATA = "signedData";

    static final String OS_KEY = "os", OS_VALUE = "android";

    static final String CARD_URL = "http://wherearemycards.com/cards/";

    static final int CODE_CANCELED = 1994;

    static final int LOAD_LIMIT = 1000;

  BuildContext context;
  ParseManager(this.context){
    init();

    //createAnonymousUser();
  }
  ParseUser? currentPUser;

  void init() async {
    await Parse().initialize(
        APP_ID,
        SERVER_ID,
        debug: true,
        registeredSubClassMap: <String, ParseObjectConstructor>{
          CardW.TABLE_NAME: () => CardW(),
          CardInfo.TABLE_NAME: () => CardInfo(null,null),
        },
        //coreStore: await CoreStoreSembastImp.getInstance(join('db.db'))
    );
    /*final installation = (await ParseInstallation.currentInstallation());
    print("installation objectId is null: "+(installation.objectId==null).toString());
    if(installation.objectId==null){
      installation.objectId = "asdasd";
    }*/
    createUserFromToken();
    //createAnonymousUser();
  }

  void createUserFromToken({BuildContext? context}) async{
    //if(ParseUser.currentUser() == null){
    SharedPreferences prefs = (await SharedPreferences.getInstance());
    if(!prefs.containsKey("session") || prefs.getString("session")==""){
      print("User session not found. Creating anonymous user");
      final func = ParseCloudFunction(CREATE_ANONYMOUS_USER);
      var token = (await func.execute());
      if(token.success){
        prefs.setString("session", token.result);
        print("Anonymous user created");
      }
      else{
        print("Anonymous user creating error!");
      }
    }
    print("User creating started");
    final resp = (await ParseUser.getCurrentUserFromServer(prefs.getString("session")!));
    print("User creating success: "+(resp?.success ?? "error").toString());
    currentPUser = await ParseUser.currentUser();
    if(resp?.success ?? false){
      print("User creating result-isAnonymous:" + (resp?.result as ParseObject).get(IS_ANONYMOUS).toString());
      //prefs.setString("session",resp?.result);
      //setCardsToProvider();
      print("User created.");
    }
    else {
      print("User not created - getCurrentUser response not success.");
    }
  }

  Future<bool> setCardsToProvider({BuildContext? context}) async{
    print("setCardsToProvider started");
    if(currentPUser == null){
      print("current user is null");
      return false;
    }
    QueryBuilder<CardW> query = QueryBuilder<CardW>(CardW());
    final response = await query.query();
    print("CardW object query success: " + response.success.toString());
    if(response.success){
      print("results: "+(response.results?.length.toString()??"null"));
      print("result: "+(response.result?.toString()??"null"));
      List<CardW> cards = await CardW.fromParseObjects(response.results as List<ParseObject>, context??this.context);
      final ch = (context??this.context).read<CardHolder>();
      ch.synchronizeCardsWithCloud(cards,currentPUser);
      //ch.synchronizeCardsWithCloud(cards, currentPUser);
      return true;
    }
    return false;
  }

  Future<bool> setPublicCardsToProvider({BuildContext? context}) async{
    print("setPublicCardsToProvider started");
    if(currentPUser == null){
      print("current user is null");
      return false;
    }
    QueryBuilder<CardW> query = QueryBuilder<CardW>(CardW());
    final response = await query.query();
    print("CardW object query success: " + response.success.toString());
    if(response.success){
      print("results: "+(response.results?.length.toString()??"null"));
      print("result: "+(response.result?.toString()??"null"));
      List<CardW> cards = await CardW.fromParseObjects(response.results as List<ParseObject>, context??this.context);
      final ch = (context??this.context).read<CardHolder>();
      ch.synchronizeCardsWithCloud(cards,currentPUser);
      //ch.synchronizeCardsWithCloud(cards, currentPUser);
      return true;
    }
    return false;
  }
}