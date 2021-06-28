import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/country.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/utils/StoreDB.dart';
import 'package:wamc/utils/localizations.dart';

class ChooseCountry extends StatelessWidget {
  ValuesNotifier values = ValuesNotifier();
  static List<String> allCountries = [
    'cars',
    'hotels_and_airlines',
    "AU",
    "AT",
    "BY",
    "BE",
    "BR",
    "CA",
    "CN",
    "CY",
    "CZ",
    "DK",
    "FI",
    "FR",
    "DE",
    "HK",
    "HU",
    "IN",
    "ID",
    "IL",
    "IT",
    "JP",
    "KR",
    "KZ",
    "MX",
    "NL",
    "NO",
    "PL",
    "RO",
    "RU",
    "SG",
    "SK",
    "SI",
    "ZA",
    "ES",
    "SE",
    "CH",
    "TW",
    "TH",
    "TR",
    "GB",
    "UA",
    "US"
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCountries = context.read<CountryHolder>().countries;
    Map<String, bool> temp = Map<String, bool>();
    for (int i = 0; i < allCountries.length; i++) {
      temp[allCountries[i]] = selectedCountries.contains(allCountries[i]);
    }
    values.values = temp;

    return ChangeNotifierProvider<ValuesNotifier>(
      create: (context) => values,
      child: _ChooseCountryState(),
    );
  }
}

class ValuesNotifier extends ChangeNotifier {
  Map<String, bool> values = Map<String, bool>();

  void setVal(String key, bool val) {
    values[key] = val;
    notifyListeners();
  }
}

class _ChooseCountryState extends StatelessWidget {
  static final String DONE = "done";

  List<String> allCountries = [
    'cars',
    'hotels_and_airlines',
    "AU",
    "AT",
    "BY",
    "BE",
    "BR",
    "CA",
    "CN",
    "CY",
    "CZ",
    "DK",
    "FI",
    "FR",
    "DE",
    "HK",
    "HU",
    "IN",
    "ID",
    "IL",
    "IT",
    "JP",
    "KR",
    "KZ",
    "MX",
    "NL",
    "NO",
    "PL",
    "RO",
    "RU",
    "SG",
    "SK",
    "SI",
    "ZA",
    "ES",
    "SE",
    "CH",
    "TW",
    "TH",
    "TR",
    "GB",
    "UA",
    "US"
  ];

  @override
  Widget build(BuildContext context) {
    ValuesNotifier values = context.read<ValuesNotifier>();
    return Scaffold(
      appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(Loc.of(context)!.tr("choose_region")),
        WatcherWidget(context.watch<CountryHolder>().countries),
        IconButton(
            onPressed: () {
              List<String> countr = [];
              for (var c in values.values.keys) {
                if (values.values[c] ?? false) countr.add(c);
              }
              if (countr.length == 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(Loc.of(context)!.tr("please_choose_region"))));
                return;
              }

              context.read<CountryHolder>().countries = countr;
              Navigator.pop(context, DONE);
            },
            icon: const Icon(Icons.done)),
      ])),
      body: Container(
          child:
          ListView.builder(
            itemCount: allCountries.length,
            itemBuilder: (context, i) {
              if (i == 0 || i == 2) {
                String text = i == 0 ? "Во всём мире" : "Страны";
                return Container(
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black12))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: EdgeInsets.only(left: 16,top: 16), child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.pink.shade300))),
                      RegionCheckboxListTile(
                          i,
                          Loc.of(context)!,
                          context.watch<ValuesNotifier>().values[allCountries[i]],
                          values)
                    ]));
              }

              return Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black12))),
                  child: RegionCheckboxListTile(
                      i,
                      Loc.of(context)!,
                      context.watch<ValuesNotifier>().values[allCountries[i]],
                      values));
            },
          ),

      ),
    );
  }
}

class WatcherWidget extends StatelessWidget {
  List<String> countries;
  WatcherWidget(this.countries);

  @override
  Widget build(BuildContext context) {
    context.read<StoreDB>().sendStoresToProvider(newContext: context);
    return Container();
  }

}

class RegionCheckboxListTile extends CheckboxListTile {
  int index;

  RegionCheckboxListTile(
      this.index, Loc loc, bool? value, ValuesNotifier values)
      : super(
            title: Text(index >= 2
                ? loc.tr(loc.tr(ChooseCountry.allCountries[index]))
                : loc.tr(ChooseCountry.allCountries[index])),
            value: value,
            onChanged: (bool? val) {
              values.setVal(ChooseCountry.allCountries[index], val!);
            });
}
