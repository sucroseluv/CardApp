import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/layers/provider_layer.dart';
import 'package:wamc/screens/main_screen.dart';
import 'package:wamc/utils/StoreDB.dart';
import 'package:wamc/utils/localizations.dart';
import 'package:wamc/utils/parse_manager.dart';

class ShowCard extends StatelessWidget {
  CardW card;

  ShowCard(this.card);

  LocalStoreHolder store = new LocalStoreHolder(null);

  @override
  Widget build(BuildContext context) {
    try {
      store._data = context.read<StoreHolder>().data.firstWhere((element) =>
          element.id == card.getInfo()!.get<int>(CardInfo.STORE_ID));
    } on Exception {
      if (store._data == null) {
        setStoreAsync(context);
      }
    }
    print("card uid: " + card.get(CardW.UID));
    return ChangeNotifierProvider<LocalStoreHolder>(
      create: (context) => store,
      child: _ShowCardSetup(card),
    );
  }

  void setStoreAsync(BuildContext context) async {
    store._data = await context
        .read<StoreDB>()
        .getStoreByIdOrName(id: card.getInfo()!.get<int>(CardInfo.STORE_ID));
  }
}

class LocalStoreHolder extends ChangeNotifier {
  Store? _data;

  LocalStoreHolder(this._data);

  Store? get data => _data;

  set data(Store? value) {
    _data = value;
    notifyListeners();
  }
}

class _ShowCardSetup extends StatelessWidget {
  CardW card;
  late BuildContext _context;
  _ShowCardSetup(this.card);

  ImageProvider imageProvider = Image.asset("assets/logos/logo3-15.png").image;

  // Some troubles with provider :/

  @override
  Widget build(BuildContext context) {
    _context = context;
    Store store = context.read<StoreHolder>().data.firstWhere(
        (element) => element.id == card.getInfo()!.get<int>(CardInfo.STORE_ID));
    final user = context.read<ParseHolder>().get()?.currentPUser;
    //imageProvider = getProvider(context.watch()<LocalStoreHolder>()._data.logo);
    /*print("showCardScreen Card info: ");
    print(card.get(CardW.UID));
    print(card.get(CardW.NUMBER));
    print(card.get(CardW.OWNER));
    print(card.get(CardW.DESCRIPTION));
    print((card.get(CardW.INFO) as CardInfo).get(CardInfo.REGION));
    print((card.get(CardW.INFO) as CardInfo).get(CardInfo.IS_PUBLIC));
    print((card.get(CardW.INFO) as CardInfo).get(CardInfo.DISCOUNT));
    print((card.get(CardW.INFO) as CardInfo).get(CardInfo.STORE_NAME));
    print((card.get(CardW.INFO) as CardInfo).get(CardInfo.STORE_ID));
    print("discount is null: "+(card.getInfo()?.get(CardInfo.DISCOUNT) !=null).toString());*/
    return Scaffold(
        appBar: AppBar(title: Text(store.name),actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              List<PopupMenuItem<String>> items = [];
              print("Card in my json: "+card.toMyJson());
              print("ACLs 1=${card.get(keyVarAcl)}");
              print("ACLs 2=${ParseACL(owner: user)}");
              //print("equals = " + (card.getACL().toString() == ParseACL(owner:user).toString()).toString());
              if(card.get(keyVarAcl).toString() == ParseACL(owner:user).toString()){
                items.add(
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(Loc.of(context)!.tr('edit')),
                    )
                );
              }
              items.add(
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text(Loc.of(context)!.tr('remove')),
                  )
              );
              return items;
            },
          ),
        ]),
        body: ImagePixels(
            imageProvider:
                getProvider(/*context.read()<LocalStoreHolder>()._data.logo*/
                    store.logo),
            builder: (context, img) {
              return Container(
                color: (img.pixelColorAt!(0, 0)),
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 50),
                        child: Image(
                            width: 200,
                            image: getProvider(store.logo ?? "empty"))),
                    Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            BarcodeWidget(
                                drawText: false,
                                data: card.get(CardW.NUMBER),
                                barcode: Barcode.code128()),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              card
                                  .get(CardW.NUMBER)
                                  .toString()
                                  .split('')
                                  .reversed
                                  .join()
                                  .replaceAllMapped(RegExp(r".{4}"),
                                      (match) => "${match.group(0)} ")
                                  .split('')
                                  .reversed
                                  .join()
                                  .trim(),
                              style: TextStyle(fontSize: 60.0),
                              maxLines: 1,
                            ),
                            Text(
                              Loc.of(context)!.tr('card_number'),
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Visibility(
                                visible: (card
                                    .getInfo()
                                    ?.get(CardInfo.DISCOUNT) !=
                                    "" &&
                                    card.getInfo()?.get(CardInfo.DISCOUNT) !=
                                        null),
                                child: Text(
                                    Loc.of(context)!.tr('discount_colon') +
                                        " " +
                                        (card.getInfo()?.get(CardInfo.DISCOUNT).toString() ?? '0') +
                                        "%"))
                          ],
                        ))
                  ],
                ),
              );
            }));
  }

  ImageProvider getProvider(String? logo) {
    return Image.asset("assets/logos/logo${logo ?? "empty"}.png").image;
  }

  void handleClick(String value) async{
    switch (value) {
      case 'edit':
        final res = await Navigator.pushNamed(_context, "/editCard", arguments: EditCardArgs(card: card));
        print("res is CardW: " + (res is CardW).toString());
        if(res is CardW){
          card = res;
          _context.read<CardHolder>().addOrUpdateCard(res);
        }
        break;
      case 'remove':
        break;
    }
  }
}
