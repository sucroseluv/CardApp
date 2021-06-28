

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/screens/choose_country.dart';
import 'package:wamc/screens/choose_own_store.dart';
import 'package:wamc/screens/choose_public_store.dart';
import 'package:wamc/screens/choose_store_screen.dart';
import 'package:wamc/screens/edit_card_screen.dart';
import 'package:wamc/screens/main_screen.dart';
import 'package:wamc/screens/show_card_screen.dart';

import 'localizations.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>MainScreen());
      case '/choosePublicStore':
        return MaterialPageRoute(builder: (_)=>ChoosePublicStoreScreen());
      case '/chooseStore':
        return MaterialPageRoute(builder: (_)=>ChooseStoreScreen());
      case '/chooseOwnStore':
        return MaterialPageRoute(builder: (_)=>ChooseOwnStoreScreen());
      case '/chooseCountry':
        return MaterialPageRoute(builder: (_)=>ChooseCountry());
      case '/showCard':
        if(args is CardW)
          return MaterialPageRoute(builder: (_)=>ShowCard(args));
        else break;
      case '/editCard':
        if(args is EditCardArgs)
          return MaterialPageRoute(builder: (_)=>EditCardScreen(
            editCard: (args).card,
            newCardStore: (args).newCardStore,
            newCardNumber: (args).newCardNumber));
        else
          break;
    }

    return _errorRoute();
  }
  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_)=> Scaffold(
      body: Center(child: Text("Error route"))
    ));
  }
}