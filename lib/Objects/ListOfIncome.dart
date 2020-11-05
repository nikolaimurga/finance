import 'package:flutter_tutorial/Objects/IncomeNote.dart';

class ListOfIncome {
  static List<IncomeNote> list = List();

  static add(IncomeNote item){
    list.add(item);
  }

  static double sum(){
    double s = 0;
    for(int i = 0; i < list.length; i++){
      s += list[i].sum;
    }
    return s;
  }
}