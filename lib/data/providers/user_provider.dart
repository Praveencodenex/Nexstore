
import 'package:flutter/material.dart';


class UserProvider with ChangeNotifier {

  int currentInd=0;
  int get currentIndex=> currentInd;
  late String _username;
  late String _email;
  late String _profileImage;
  String? _error;


  String get username => _username;
  String get email => _email;
  String get profileImage => _profileImage;
  String? get error => _error;

  setCurrentIndex(int index){
    currentInd=index;
    notifyListeners();
  }

}
