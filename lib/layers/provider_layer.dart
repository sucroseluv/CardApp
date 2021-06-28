import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/country.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/layers/database_layer.dart';
import 'package:wamc/utils/StoreDB.dart';
import 'package:wamc/utils/parse_manager.dart';


class ProviderLayer extends StatelessWidget{
  CountryHolder countryHolder = CountryHolder();
  ParseHolder parseManager = ParseHolder();
  StoreDB storeDB = StoreDB();
  StoreHolder storeHolder = StoreHolder();
  TagsHolder tagsHolder = TagsHolder();
  CardInfoHolder cardInfoHolder = CardInfoHolder();
  CardHolder cardHolder = CardHolder();
  PublicCardsHolder publicCardsHolder = PublicCardsHolder();

  @override
  Widget build(BuildContext context) {
    storeDB.context = context;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ParseHolder> ( create: (context) => parseManager ),
          Provider<StoreDB> ( create: (context) => storeDB ),
          ChangeNotifierProvider<CountryHolder> ( create: (context) => countryHolder ),
          ChangeNotifierProvider<StoreHolder> (  create: (context) => storeHolder ),
          ChangeNotifierProvider<TagsHolder> ( create: (context) => tagsHolder,),
          ChangeNotifierProvider<CardHolder> ( create: (context) => cardHolder,),
          ChangeNotifierProvider<CardInfoHolder> ( create: (context) => cardInfoHolder,),
        ],
        builder: (newContext, lel){ storeDB.context = newContext; return DatabaseLayer(); },
    );
  }
}

class TagsHolder with ChangeNotifier {
  Map<int, List<String>> data = Map<int, List<String>>();
}

class ParseHolder with ChangeNotifier {
  ParseManager? _parseManager = null;

  void createParseManager(BuildContext context){
    _parseManager = ParseManager(context);
    notifyListeners();
  }

  ParseManager? get(){
    return _parseManager;
  }

}