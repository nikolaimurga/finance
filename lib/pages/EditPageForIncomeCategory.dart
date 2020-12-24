import 'dart:convert';
import 'package:flutter/material.dart';
import '../pages/Calculator.dart';
import '../setting/DateFormatText.dart';
import '../setting/MainLocalText.dart';
import '../setting/SecondaryLocalText.dart';
import '../widgets/rowWithButton.dart';
import '../widgets/rowWithWidgets.dart';
import '../Objects/IncomeNote.dart';
import '../Objects/ListOfIncomes.dart';
import '../Utility/Storage.dart';
import '../pages/ListOfIncomesCategories.dart';
import '../setting/MyColors.dart';
import '../setting/MainRowText.dart';

class EditPageForIncomeCategory extends StatefulWidget {
  final Function updateIncomePage;
  final Function updateMainPage;
  final IncomeNote note;

  EditPageForIncomeCategory({
    this.updateIncomePage,
    this.updateMainPage,
    this.note
  });

  @override
  _EditPageForIncomeCategoryState createState() =>
      _EditPageForIncomeCategoryState(this.note);
}

class _EditPageForIncomeCategoryState extends State<EditPageForIncomeCategory> {
  IncomeNote currentNote;
  TextEditingController calcController = TextEditingController();

  _EditPageForIncomeCategoryState(this.currentNote);

  void updateCategory(String cat) {
    setState(() {
      currentNote.category = cat;
    });
  }

  void updateSum(double result){
    setState(() {
      //if (calcController != null) calcController.text = result.toString();
      currentNote.sum = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.backGroundColor,
        bottomNavigationBar: buildBottomAppBar(),
        //appBar: buildAppBar(),
        body: buildBody()
      ),
    );
  }

  Widget buildBottomAppBar() {
    return BottomAppBar(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            color: MyColors.mainColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 5
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context)
            ),
            MainLocalText(text: "Редактирование"),
            IconButton(
                iconSize: 35,
                icon: Icon(Icons.done, color: MyColors.textColor),
                onPressed: (){
                  updateListOfIncomes();
                  widget.updateIncomePage();
                  widget.updateMainPage();
                  Navigator.pop(context);
                }
            ),
          ],
        ),
      ),

    );
  }

  Widget buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(
        color: MyColors.textColor,
      ),
      backgroundColor: MyColors.mainColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MainRowText(text: "Редактирование"),
          IconButton(
            iconSize: 35,
            icon: Icon(Icons.done, color: MyColors.textColor),
            onPressed: (){
              updateListOfIncomes();
              widget.updateIncomePage();
              widget.updateMainPage();
              Navigator.pop(context);
            }
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 35),
              RowWithWidgets(
                  leftWidget: MainLocalText(text: 'Дата'),
                  rightWidget: (currentNote.date != null)?
                  DateFormatText(
                      dateTime: currentNote.date,
                      mode: 'Дата в строке'
                  )
                      : SecondaryLocalText(text: 'Выбирите дату'),
                  onTap: onDateTap
              ),
              SizedBox(height: 30),
              RowWithButton(
                leftText: 'Категория',
                rightText: currentNote.category,
                onTap: () => onCategoryTap(context),
              ),
              SizedBox(height: 30),
              Container(
                height: 100,
                child: IconButton(
                    icon: Icon(
                        Icons.calculate_outlined,
                        color: MyColors.textColor,
                        size: 40
                    ),
                    onPressed: () => goToCalculator(context)
                ),
              ),
              // sum row
              Container(
                height: 75,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: currentNote.sum.toString(),
                  decoration: const InputDecoration(
                    hintText: 'Введите сумму',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Пожалуйста введите сумму';
                    }
                    return null;
                  },
                  onChanged: (v) => currentNote.sum = double.parse(v),
                ),
              ),
              Container(
                height: 75,
                child: TextFormField(
                  initialValue: currentNote.comment,
                  decoration: const InputDecoration(
                    hintText: 'Введите коментарий',
                  ),
                  onChanged: (v) => currentNote.comment = v,
                ),
              ),
            ],
          ),
        ),
      );
  }

  goToCalculator(BuildContext context){
    Navigator.push(
        context,
        MaterialPageRoute <void>(
            builder: (BuildContext context) {
              return Calculator(updateSum: updateSum, result: currentNote.sum);
            }
        )
    );
  }

  updateListOfIncomes() async{
    int index = ListOfIncomes.list.indexOf(widget.note);
    ListOfIncomes.list[index] = currentNote;
    await Storage.saveString(jsonEncode(ListOfIncomes().toJson()), 'IncomeNote');
  }

  onCategoryTap(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return ListOfIncomesCategories(callback: updateCategory, cat: currentNote.category);
            }
        )
    );
  }

  Widget getDateWidget(DateTime date) {
    return FlatButton(
      onPressed: onDateTap,
      child: (date != null)? MainRowText(
        text: date.toString().substring(0, 10),
        align: TextAlign.left,
      ) : MainRowText(text: 'Выберите дату'),
    );
  }

  onDateTap() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 184)),
      firstDate: DateTime.now().subtract(Duration(days: 184)),
      builder:(BuildContext context, Widget child) {
        return theme(child);
      },
    );
    setState(() {
      currentNote.date = picked;
    });
  }

  theme(Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: MyColors.mainColor,
          onPrimary: MyColors.textColor,
          surface: MyColors.mainColor,
          onSurface: MyColors.textColor,
        ),
        dialogBackgroundColor: MyColors.backGroundColor,
      ),
      child: child,
    );
  }

}
