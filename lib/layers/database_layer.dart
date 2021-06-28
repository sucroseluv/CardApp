

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/country.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/layers/provider_layer.dart';
import 'package:wamc/screens/main_screen.dart';
import 'package:wamc/utils/StoreDB.dart';
import 'package:wamc/utils/parse_manager.dart';

import '../main.dart';

class DatabaseLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //context.read<StoreDB>().sendStoresToProvider(newContext: context);
    context.read<ParseHolder>().createParseManager(context);
    setupCardsPref(context);
    setupStores(context);
    return MyApp();
  }
  void setupStores(BuildContext context) async{
    final res = (await SharedPreferences.getInstance()).getString('countries');
    context.read<CountryHolder>().setCountriesFromString(
        (res ?? "'RU','BY'"));
    context.read<StoreDB>().sendStoresToProvider(newContext: context);
  }
  void setupCardsPref(BuildContext context) async{
    await context.read<CardInfoHolder>().loadFromStorage();
    await context.read<CardHolder>().loadFromStorage(context.read<CardInfoHolder>());
    await context.read<ParseHolder>().get()?.setCardsToProvider(context: context);
  }
}