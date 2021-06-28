import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/layers/provider_layer.dart';
import 'package:wamc/screens/main_screen.dart';
import 'package:wamc/utils/localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ChooseOwnStoreScreen extends StatelessWidget {
  FieldText text = FieldText();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FieldText>(create: (context)=>text,
    child: ChooseOwnStoreScreenSetup(),);
  }

}

class FieldText with ChangeNotifier{
  String _text = "";

  String get text => _text;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

}

class ChooseOwnStoreScreenSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Store> stores = context.read<StoreHolder>().data;
    Map<int,List<String>> tags = context.read<TagsHolder>().data;

    return Scaffold(
        appBar: AppBar(
            title:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Loc.of(context)!.tr("app_name")),
                IconButton(icon: Icon(Icons.done),onPressed: (){
                  Navigator.of(context).pop(context.read<FieldText>()._text);
                },),
              ],
            ),

        ),
        body: Container(
            padding: EdgeInsets.all(10),
            height: 80,
            child:
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  )
              ),
              suggestionsCallback: (pattern) async {
                  context.read<FieldText>()._text = pattern;
                  List<Store> res = [];
                  res.addAll(stores.where((e) => (tags[e.id??0] ?? []).any((el) => el.startsWith(pattern))));
                  res.addAll(stores.where((e) => !res.contains(e) && (e.name.startsWith(pattern))));
                  res.addAll(stores.where((e) => !res.contains(e) && (tags[e.id??0] ?? []).any((el) => el.contains(pattern))));
                  res.addAll(stores.where((e) => !res.contains(e) && (e.name.contains(pattern))));
                  return res;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: (Image.asset("assets/logos/logo${(suggestion as Store).logo ?? "assets/logos/empty" }.png" ,width: 40,)),
                  title: Text((suggestion as Store).name),
                );
              },
              onSuggestionSelected: (suggestion) {
                Navigator.of(context).pop((suggestion as Store).id);
              },
            )

        )
    );
  }
}
