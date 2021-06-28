import 'package:flutter/material.dart';
import 'package:wamc/layers/provider_layer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wamc/utils/route_generator.dart';

import 'utils/localizations.dart';

void main() {
  runApp(ProviderLayer());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        Loc.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('ru', ''), // Russian, no country code
        Locale('cn', ''), // China, no country code
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: '/',
    );
  }
}
