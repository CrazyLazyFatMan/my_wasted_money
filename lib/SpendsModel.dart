import 'package:scoped_model/scoped_model.dart';
import 'ConnectionDB.dart';
import 'Spends.dart';



class SpendsModel extends Model{
  WastedDB _database;

  SpendsModel() {
    _database = WastedDB();
    load();
  }

  List<Spends> _spends = [
    Spends(0, DateTime.now(), "TEMPLATE", 1000),
  ];


  void load([bool part, DateTime fDate, DateTime sDate]) {
    Future<List<Spends>> future =_database.getEveryWaste(part, fDate, sDate);
    future.then((list) {
      _spends = list;
      notifyListeners();

    });
  }

  int get length => _spends.length;

  String getKey(int index) {
    return _spends[index].id.toString();
  }

  String getText(int index) {
    var spend = _spends[index];
    String date = "${spend.date.year}-${spend.date.month}-${spend.date.day}";
    return spend.name + " for " + spend.price.toString() + "\n" + date;
  }

  String getTotals() {
    double total = 0;
    for (int i = 0; i < _spends.length; i++)
    {
      total = total + _spends[i].price;
    }
    return total.toString();
  }

  void removingAt(int index) {
    int id = _spends[index].id;
    _spends.removeAt(index);
    notifyListeners();
    Future<void> future = _database.deleteSpend(id);
    future.then((_) {
      load();
    });
  }

  Spends getSpend(int index) {
    return _spends[index];
  }

  void addingTitle(String name, double price, DateTime date) {
    // var e = Spends(_spends.length + 1, DateTime.now(), name, price);
    // _spends.add(e);
    // notifyListeners();
    Future<void> future = _database.newSpend(name, price, date);
    future.then((_) {
      load();
    });
  }

  void editingTitle(String name, double price, DateTime date, int id) {
    Future<void> future = _database.updateSpend(name, price, date, id);
    future.then((_) {
      load();
    });
  }

}