

import 'package:flutter/cupertino.dart';

class Store {
  int? id;
  String name;
  String? logo;
  int isDeleted;
  String? homepage;

  Store(this.name,{this.id, this.logo, this.isDeleted = 0, this.homepage});
}

class StoreHolder with ChangeNotifier{
  List<Store> _data = [];

  StoreHolder();

  List<Store> get data => _data;

  set data(List<Store> value) {
    _data = value;
    notifyListeners();
  }
}

class AllStoresHolder with ChangeNotifier{
  List<Store> _data = [];

  AllStoresHolder();

  List<Store> get data => _data;

  set data(List<Store> value) {
    _data = value;
    notifyListeners();
  }
}