import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../setting/SecondaryLocalText.dart';
import '../pages/Calculator.dart';
import '../setting/DateFormatText.dart';
import '../setting/MainLocalText.dart';
import '../widgets/rowWithButton.dart';
import '../widgets/rowWithWidgets.dart';
import '../Objects/ExpenseNote.dart';
import '../Objects/ListOfExpenses.dart';
import '../Utility/Storage.dart';
import '../pages/ListOfExpensesCategories.dart';
import '../setting/MyColors.dart';
import '../setting/MainRowText.dart';

class EditPageForExpenseCategory extends StatefulWidget {
  final Function updateExpensePage;
  final Function updateMainPage;
  final ExpenseNote note;

  EditPageForExpenseCategory({
    this.updateExpensePage,
    this.updateMainPage,
    this.note
  });

  @override
  _EditPageForExpenseCategoryState createState() =>
      _EditPageForExpenseCategoryState(this.note);
}

class _EditPageForExpenseCategoryState extends State<EditPageForExpenseCategory> {
  ExpenseNote currentNote;
  TextEditingController calcController = TextEditingController();

  _EditPageForExpenseCategoryState(this.currentNote);

  void updateCategory(String cat) {
    setState(() {
      currentNote.category = cat;
    });
  }

  void updateSum(double result){
    setState(() {
      //if (currentNote.sum != result) calcController.text = result.toString();
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
        body: buildBody(),
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
                        updateListOfExpenses();
                        widget.updateExpensePage();
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
          MainLocalText(text: "Редактирование"),
          IconButton(
            iconSize: 35,
            icon: Icon(Icons.done, color: MyColors.textColor),
            onPressed: (){
              updateListOfExpenses();
              widget.updateExpensePage();
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
          children: <Widget>[
            SizedBox(height: 35),
            // date widget row
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

  updateListOfExpenses() async{
    int index = ListOfExpenses.list.indexOf(widget.note);
    ListOfExpenses.list[index] = currentNote;
    await Storage.saveExpenseNote(null, currentNote.category);
  }

  onCategoryTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context){
          return ListOfExpensesCategories(
            callback: updateCategory, 
            cat: currentNote.category
          );
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

  void dispose() {
    calcController.dispose();
    super.dispose();
  }

}
