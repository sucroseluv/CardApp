
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryHolder with ChangeNotifier{
  List<String> _countries = [];
  List<String> get countries => _countries;

  set countries(List<String> value) {
    _countries = value;
    notifyListeners();
    setPreferences();
  }
  
  void addCountry(String countryCode){
    if(!_countries.contains(countryCode)){
      countries.add(countryCode);
      notifyListeners();
      setPreferences();
    }
  }
  void setCountriesFromString(String value){
    value = value.replaceAll("'", "");
    _countries = value.split(',');
  }
  
  String getCountriesString(){
    String res = "";
    for (int i = 0; i < _countries.length; i++) {
      res+="'${_countries[i]}',";
    }
    return res.substring(0,res.length-1);
  }

  void setPreferences() async{
    (await SharedPreferences.getInstance()).setString('countries', getCountriesString());
  }
}