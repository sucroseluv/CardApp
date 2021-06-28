import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/country.dart';
import 'package:wamc/data/store.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wamc/layers/provider_layer.dart';
import 'package:wamc/utils/StoreDB.dart';
import 'package:wamc/utils/parse_manager.dart';
import '../utils/localizations.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Loc.of(context)!.tr('app_name')),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => fabPressed(context),
        ),
        body: Container(
            child: GridViewCards(context.watch<CardHolder>())
        ));
  }

  fabPressed(BuildContext context) async {
    /*print("parsed cards count: " + (context.read<CardHolder>().data.length.toString()));
    final ch = context.read<CardHolder>();
    print(ch.data[0].get(keyVarUpdatedAt).toString());
    ch.data[0].set(CardW.DESCRIPTION,"new value");
    ch.data[0].toJson();
    return;*/
    /*final stre = context.read<StoreHolder>().data[4];
    final ci = CardInfo(stre.id,stre.name);
    CardW c = CardW()..setInfo(ci);
    c.set(CardW.NUMBER,"12423514232");
    c.set(CardW.DESCRIPTION,"Descr");
    Navigator.of(context).pushNamed("/showCard",arguments: c);
    return;
    */
    final dialogResult = await showDialog<String>(
        context: context,
        builder: (context){
          return ChooseCardTypeDialog();
        });
    if(dialogResult == null){
      print("user didn't choose type of adding card");
      return;
    }

    if(dialogResult == "own"){
      final store = await Navigator.of(context).pushNamed(
          "/chooseStore", arguments: context);
      if (store is String || store is int) {
        Store intentStore = (store is String) ? Store(store) : context
            .read<StoreHolder>()
            .data
            .firstWhere((element) => element.id == store);

        try {
          final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              "#0000ff",
              Loc.of(context)!.tr('not_scan'),
              false,
              ScanMode.BARCODE);
          final args = EditCardArgs(
              newCardStore: intentStore, newCardNumber: barcodeScanRes);
          final c = await Navigator.of(context).pushNamed(
              "/editCard", arguments: args);
          if (c is CardW) {
            print("card creating");
            CardW? createdCard = await CardW.createCard(c);
            if(createdCard != null){
              print("created card id: " + (createdCard.objectId ?? "nothing"));
              print("created card info id: " + (createdCard.getInfo()?.get(keyVarObjectId) ?? "nothing"));
              context.read<CardHolder>().addOrUpdateCard(createdCard);
              //print(c.get<String>(CardW.DESCRIPTION));
              Navigator.of(context).pushNamed("/showCard", arguments: createdCard);
            }

          }
        }
        on PlatformException {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(Loc.of(context)!.tr('barcode_error'))));
        }
      }
    }
    else if(dialogResult == "public"){
      final store = await Navigator.of(context).pushNamed(
          "/choosePublicStore", arguments: context);
    }
    else
      print("error card type choose");
  }
}

class GridViewCards extends StatelessWidget {
  CardHolder cards;
  GridViewCards(this.cards);

  @override
  Widget build(BuildContext context) {
    //List<Store> stores = context.read<StoreHolder>().data;
    final db = context.read<StoreDB>();
    return GridView.builder(
        itemCount: cards.data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: ()=>Navigator.of(context).pushNamed("/showCard",arguments: cards.data[index]) ,
            child: Container(
                child: FutureBuilder<Store?>(
                  future: db.getStoreByIdOrName(id: cards.data[index].getInfo()?.get(CardInfo.STORE_ID) ?? -1),
                  builder: (BuildContext context, AsyncSnapshot<Store?> store){
                    return Image.asset("assets/logos/logo${store.data?.logo ?? "empty"}.png");
                  },
                ),
            ),
          );
        });
  }/*
  Future<Image> getImage(StoreDB db, int id) async{
    Store? store = await db.getStoreByIdOrName(id: id);
    if(store != null)
      return Image.asset("assets/logos/logo${store!.logo}.png");
    return Image.asset("assets/logos/logoempty.png");
  }*/
}


class EditCardArgs {
  Store? newCardStore = null;
  String? newCardNumber = null;
  CardW? card = null;

  EditCardArgs({this.newCardStore, this.newCardNumber, this.card});
}

class ChooseCardTypeDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
        height: 150,
        width: 100,
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){Navigator.of(context).pop("own");},
                  child: Center(
                    child: Container(
                      child: Text(Loc.of(context)!.tr("add_card_variants_1"),style: TextStyle(fontSize: 16),),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){Navigator.of(context).pop("public");},
                  child: Center(
                    child: Container(
                      child: Text(Loc.of(context)!.tr("add_card_variants_2"),style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

}