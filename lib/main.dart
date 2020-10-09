import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

// import 'package:my_wasted_money/Spends.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'EditSpend.dart';
import 'SpendsModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wasted Money',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'MY WASTED MONEY'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  get model => SpendsModel();

  bool isParted = false;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SpendsModel>(
      model: SpendsModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ScopedModelDescendant<SpendsModel>(
              builder: (context, child, model) {
            if (model.length == 0 && !isParted)
              return Center(
                  child: Text('Hmm, looks like you know how money works',
                      textAlign: TextAlign.center));
            return ListView.separated(
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                        title: Text(
                            "You waste " + model.getTotals() + " of money"),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.filter_list),
                          itemBuilder: (BuildContext context) =>
                              _showPopupItems(isParted),
                          onSelected: (res) async {
                            if (res == 0) {
                              isParted = true;
                              var currentDate = new DateTime.now();
                              final List<DateTime> chosenDates =
                                  await DateRangePicker.showDatePicker(
                                      context: context,
                                      initialFirstDate: new DateTime(
                                          currentDate.year,
                                          currentDate.month,
                                          1),
                                      initialLastDate: new DateTime(
                                              currentDate.year,
                                              currentDate.month + 1,
                                              1)
                                          .subtract(new Duration(days: 1)),
                                      firstDate: new DateTime(2019),
                                      lastDate: new DateTime(2030));

                              if (chosenDates != null) {
                                if (chosenDates.length == 2)
                                  model.load(
                                      true,
                                      new DateTime(chosenDates[0].year,
                                          chosenDates[0].month, chosenDates[0].day),
                                      new DateTime(chosenDates[1].year,
                                              chosenDates[1].month, chosenDates[1].day)
                                          .add(Duration(days: 1)));
                                else
                                  model.load(
                                      true,
                                      new DateTime(chosenDates[0].year,
                                          chosenDates[0].month, chosenDates[0].day),
                                      new DateTime(chosenDates[0].year,
                                              chosenDates[0].month, chosenDates[0].day)
                                          .add(Duration(days: 1)));
                              }
                            } else {
                              isParted = false;
                              model.load();
                            }
                          },
                        ));
                  } else {
                    index -= 1;
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.17,
                      child: Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(model.getText(index)),
                          subtitle: Align(
                            child: Text("swipe right fot more options"),
                            alignment: Alignment(-1, 0),
                          ),
                          // contentPadding: EdgeInsets.symmetric(vertical: 15.0) ,
                        ),
                      ),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            return confirmDeleting(context, index, model);
                          },
                        ),
                        IconSlideAction(
                            caption: 'Edit tile',
                            color: Colors.black45,
                            icon: Icons.edit,
                            onTap: () => {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return EditSpend(model, index, true);
                                    },
                                  ))
                                }),
                      ],
                    );
                  }
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: model.length + 1);
          }),
          floatingActionButton: ScopedModelDescendant<SpendsModel>(
            builder: (context, child, model) => FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                // model.addingTitle("House", 10000);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return EditSpend(model, -999999, false);
                  },
                ));
              },
            ),
          )),
    );
  }

  void confirmDeleting(BuildContext context, int index, model) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Are you sure you want to delete this waste?'),
              content: Text('It will not return (really)'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => {Navigator.pop(context)},
                ),
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => {
                    model.removingAt(index),
                    index += 1,
                    Navigator.pop(context, true)
                  },
                ),
              ]);
        });
  }

  List<PopupMenuEntry> _showPopupItems(bool parted) {
    if (parted) {
      return <PopupMenuEntry>[
        const PopupMenuItem(
          value: 0,
          child: Text('Set up period'),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text('Reset period'),
        )
      ];
    } else {
      return <PopupMenuEntry>[
        const PopupMenuItem(
          value: 0,
          child: Text('Set up period'),
        )
      ];
    }
  }
}
