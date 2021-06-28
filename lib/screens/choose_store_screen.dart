import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wamc/data/store.dart';
import 'package:wamc/utils/localizations.dart';
import 'package:wamc/utils/parse_manager.dart';
import "package:collection/collection.dart";

class ChooseStoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChooseStoreScreenSetup(context
        .watch<StoreHolder>().data);
  }

}

class _ChooseStoreScreenSetup extends StatelessWidget {
  List<Store> rawData;
  _ChooseStoreScreenSetup(this.rawData);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(Loc.of(context)!.tr("app_name")),
            IconButton(onPressed: (){
              Navigator.of(context).pushNamed("/chooseCountry");
            }, icon: Icon(Icons.public))
        ])
        ),
      body: Container(
          child: GroupedListView(context
              .watch<StoreHolder>()
              .data)
      ),
    );
  }
}

class GroupedListView extends StatelessWidget {
  List<Store> rawData;
  GroupedListView(this.rawData);

  @override
  Widget build(BuildContext context) {
    Map<String, List<Store>> data = groupBy(rawData
      ..sort((a, b) {
        return a.name.compareTo(b.name);
      })
        , (store) {
          return store.name[0];
        });

    return Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
        itemCount: data.length + 1,
        itemBuilder: (context, index)
        {
          if(index==0)
            return Container(
            padding: EdgeInsets.only(left:10,right: 10),
            child: InkWell(
              onTap: () async{
                dynamic ans = await Navigator.of(context).pushNamed("/chooseOwnStore");
                if(ans != null && (ans is int || (ans is String && (ans) != ""))){
                  Navigator.of(context).pop(ans);
                }
              },
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
                  padding: EdgeInsets.all(10),
                  child:
                  Row(children: [
                    Image.asset(('assets/images/card.png'),
                      width: 50,),
                    Container(width: 100,),
                    Expanded(child:
                    Text(Loc.of(context)!.tr('own_card'),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),)),
                  ])),
            ),
          );
          return Column(
            children: [
              Container(child: Text(data.keys.elementAt(index-1),style: TextStyle(color:Colors.pink)), alignment: Alignment(-1,0), padding: EdgeInsets.only(top: 20, left: 10),),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: (data[data.keys.elementAt(index-1)]?.length ?? 0),
                itemBuilder: (context,i){
                  return Container(
                    padding: EdgeInsets.only(left:10,right: 10),
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).pop(data[data.keys.elementAt(index-1)]?[i].id);
                      },
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
                          padding: EdgeInsets.all(10),
                          child:
                          Row(children: [
                            Image.asset(('assets/logos/logo${((data[data.keys.elementAt(index-1)]?[i].logo) ?? 'emptyLogo')}.png'),
                              width: 50,),
                            Container(width: 100,),
                            Expanded(child:
                              Text(data[data.keys.elementAt(index-1)]?[i].name ?? "Empty Store (Error)",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),)),
                          ])),
                    ),
                  );
                }),
            ]
          );
        }));
  }
}