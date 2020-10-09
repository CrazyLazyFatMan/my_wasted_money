import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'ConnectionDB.dart';
import 'Spends.dart';
import 'SpendsModel.dart';

class _EditSpendState extends State<EditSpend> {
  double _price;
  String _name;
  DateTime _date;
  // WastedDB _database;
  SpendsModel _model;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _index;
  bool _editing;

  String _oldName = "";
  double _oldPrice = 0;
  DateTime _oldDate = DateTime.now();
  bool _toEdit = false;
  int _id;

  _EditSpendState(this._model, this._index, this._editing);

  @override
  Widget build(BuildContext context) {
    if (_editing)
      {
        Spends spend = _model.getSpend(_index);
        _oldName = spend.name;
        _oldPrice = spend.price;
        _oldDate = spend.date;
        _toEdit = true;
        _id = spend.id;
      }
    return Scaffold(
        appBar: AppBar(title: Text("Add new waste")),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      initialValue: _oldName,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        hintText: 'Name of your`s waste',
                        labelText: 'Name'
                      ),
                      autovalidate: true,
                      autofocus: true,
                      onSaved: (value) {
                        _name = value;
                      },
                      validator: (value) {
                        if (value.trim().isEmpty)
                          return 'Field cannot be empty';
                        return null;
                      }),
                  TextFormField(
                    initialValue: _oldPrice.toString(),
                    decoration: InputDecoration(
                        icon: Icon(Icons.monetization_on),
                        hintText: 'Price of your`s waste',
                        labelText: 'Price'
                    ),
                    autovalidate: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      var ind = value.indexOf('.');
                      if (ind == -1) ind = value.length;
                      final price = double.tryParse(value);
                      if (value.trim().isEmpty)
                        return 'Field cannot be empty';
                      if (price == null || ind > 12) return 'Price is invalid';

                      if (price < 0) return 'Negative price forbidden';

                      if (ind != -1 && ind < value.length - 6)
                        return 'Too much accuracy';
                      return null;
                    },
                    onSaved: (value) {
                      _price = double.parse(value);
                    },
                  ),
                  // DateTimeField(),
                  DateTimeFormField(
                      initialValue: _oldDate,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: 'Date of your`s waste',
                          labelText: 'Date'
                      ),
                      onSaved: (value) {
                        _date = DateTime(value.year, value.month, value.day);
                      }),
                  RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          if (!_toEdit) {
                            _model.addingTitle(_name, _price, _date);
                          } else {
                            _model.editingTitle(_name, _price, _date, _id);
                          }

                          Navigator.pop(context);
                        }
                      },
                      child: Text('Submit')),
                ],
              )),
        ));
  }
}

class EditSpend extends StatefulWidget {
  final SpendsModel _model;
  final int _index;
  final bool _editing;
  EditSpend(this._model, this._index, this._editing);

  @override
  State<StatefulWidget> createState() => _EditSpendState(_model, _index, _editing);
}
