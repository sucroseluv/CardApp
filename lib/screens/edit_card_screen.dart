import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/card.dart';
import 'package:wamc/data/card_info.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/screens/choose_country.dart';
import 'package:wamc/utils/localizations.dart';

class EditCardScreen extends StatefulWidget {
  Store? newCardStore = null;
  String? newCardNumber = null;
  CardW? editCard = null;

  EditCardScreen({this.editCard, this.newCardStore, this.newCardNumber});

  @override
  State<StatefulWidget> createState() {
    return _EditCardScreenSetup(
        newCardStore: newCardStore,
        newCardNumber: newCardNumber,
        card: editCard);
  }
}

class _EditCardScreenSetup extends State<EditCardScreen> {
  Store? newCardStore = null;
  String? newCardNumber = null;
  CardW? card = null;
  var isEdit = false;
  _EditCardScreenSetup({this.newCardStore, this.newCardNumber, this.card}){

    isEdit = card != null;
    if (!isEdit) {
      CardInfo info = CardInfo(newCardStore?.id, newCardStore?.name ?? "");
      card = CardW();
      card?.setInfo(info);
      newCardNumber = newCardNumber == "-1" ? null : newCardNumber;
      cardNumber.text = newCardNumber ?? "";

      print("id,name: ${newCardStore?.id},${newCardStore?.name}");
    } else {
      isPublic = card?.getInfo()?.get<bool>(CardInfo.IS_PUBLIC) ?? false;
      cardNumber.text = card!.get<String>(CardW.NUMBER) ?? "";
      description.text = card!.get<String>(CardW.DESCRIPTION) ?? "";
      discount.text = card?.getInfo()?.get<String>(CardInfo.DISCOUNT) ?? "";

    }
  }

  TextEditingController cardNumber = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController discount = TextEditingController();

  String? cardNumberError = null;
  String? descriptionError = null;
  String? discountError = null;

  bool isPublic = false;
  String locationValue = "";

  Future<Store> getStoreAsync(StoreHolder storeHolder, int id) async {
    return storeHolder.data.firstWhere((element) => element.id == id);
  }

  @override
  Widget build(BuildContext context) {
    cardNumber.addListener(() {
      final text = cardNumber.text;
      cardNumber.value = cardNumber.value.copyWith(
        text: text,
      );
    });
    description.addListener(() {
      final text = description.text;
      description.value = description.value.copyWith(
        text: text,
      );
    });
    discount.addListener(() {
      final text = discount.text.toString();
      discount.value = discount.value.copyWith(
        text: text,
      );
    });
/*
    var isEdit = false;
    isEdit = card != null;
    if (!isEdit) {
      CardInfo info = CardInfo(newCardStore?.id, newCardStore?.name ?? "");
      info.set(CardInfo.IS_PUBLIC, false);
      card = CardW();
      card!.set(CardW.NUMBER, newCardNumber);
      card?.setInfo(info);
      newCardNumber = newCardNumber == "-1" ? null : newCardNumber;
      cardNumber.text = newCardNumber ?? "";


      print("id,name: ${newCardStore?.id},${newCardStore?.name}");
    } else {
      setState(() {
        //isPublic = card?.getInfo()?.get<bool>(CardInfo.IS_PUBLIC) ?? false;
        cardNumber.text = card!.get<String>(CardW.NUMBER) ?? "";
      });

        description.text = card!.get<String>(CardW.DESCRIPTION) ?? "";
        discount.text = card?.getInfo()?.get<String>(CardInfo.DISCOUNT) ?? "";

    }*/
    print(
        "StoreID: " + card!.getInfo()!.get<int>(CardInfo.STORE_ID).toString());
    final store = context.read<StoreHolder>().data.firstWhere((element) =>
        element.id == card!.getInfo()!.get<int>(CardInfo.STORE_ID));
    final imageProvider =
        Image.asset("assets/logos/logo${store.logo}.png").image;
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          ImagePixels(
              imageProvider: imageProvider,
              builder: (context, img) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  height: 300,
                  color: img.pixelColorAt!(0, 0),
                  child: Image(image: imageProvider),
                  margin: EdgeInsets.only(bottom: 10),
                );
              }),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  child: ListView(
                    children: [
                          CheckboxListTile(
                          value: isPublic,
                          contentPadding: EdgeInsets.all(0),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(Loc.of(context)!.tr('public_label')),
                          onChanged: (bool? value) {
                            setState(() {
                              isPublic=value??false;
                            });
                          }),
                      Visibility(
                        visible: isPublic,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20, left: 10,right: 10),
                          child: (
                            DropdownButton(
                              onChanged: (String? val){
                                setState(() {
                                  locationValue = val ?? "";
                                });
                              },
                              value: locationValue,
                              items:  ([""] + ChooseCountry.allCountries).map((e) => DropdownMenuItem<String>(value: e, child:
                                Text( (e.length > 2) ? Loc.of(context)!.tr(e) : (e.length < 1 ? Loc.of(context)!.tr('choose_your_region') : Loc.of(context)!.tr(Loc.of(context)!.tr(e))))
                            )).toList(),
                            )
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: cardNumber,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            errorText: cardNumberError,
                            border: OutlineInputBorder(),
                            labelText: Loc.of(context)!.tr("card_number")),
                      ),
                      Container(
                        height: 10,
                      ),
                      TextFormField(
                        controller: description,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: Loc.of(context)!.tr("description")),
                      ),
                      Container(
                        height: 10,
                      ),
                      TextFormField(
                        controller: discount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            errorText: discountError,
                            border: OutlineInputBorder(),
                            labelText: Loc.of(context)!.tr("discount_hint")),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                                child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                            Loc.of(context)!.tr('cancel'))))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (cardNumber.text == "") {
                                      setState(()=>
                                      cardNumberError = Loc.of(context)!
                                          .tr("please_enter_card_number"));
                                      return;
                                    } else
                                      setState(() {
                                        cardNumberError = null;
                                      });

                                    if (discount.text !=
                                        "") if (int.parse(discount.text) <
                                            0 ||
                                        int.parse(discount.text) > 100) {
                                      setState(() {
                                        discountError = Loc.of(context)!
                                            .tr("discount_should_be");
                                      });
                                      return;
                                    } else
                                      setState(() {
                                        discountError = null;
                                      });
                                    else
                                      setState(() {
                                        discountError = null;
                                      });
                                    if(isPublic){
                                      if(locationValue==""){
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Loc.of(context)!.tr('please_choose_region')),));
                                        return;
                                      }
                                    }

                                    if(!isEdit){
                                      CardInfo ci = CardInfo(newCardStore?.id, newCardStore?.name);
                                      card?.setInfo(ci);
                                    }

                                    card?.set(CardW.NUMBER, cardNumber.text);
                                    card?.set(
                                        CardW.DESCRIPTION, description.text);
                                    card?.set(
                                      CardW.OWNER, ParseUser.currentUser()
                                    );
                                    if(!isEdit)
                                      card?.setACL(ParseACL());
                                    if(discount.text != "")
                                      card
                                          ?.getInfo()!
                                          .set(CardInfo.DISCOUNT, int.parse(discount.text));
                                    card
                                        ?.getInfo()!
                                        .set(CardInfo.IS_PUBLIC, isPublic);
                                    if(isPublic)
                                      card
                                          ?.getInfo()!
                                          .set(CardInfo.REGION, locationValue);

                                    Navigator.of(context).pop(card);
                                  },
                                  child: Container(
                                      margin: EdgeInsets.all(10),
                                      child:
                                          Text(Loc.of(context)!.tr('done')))),
                            ),
                          ),
                        ],
                      )
                    ],
                  )))
        ],
      )),
    );
  }
}
