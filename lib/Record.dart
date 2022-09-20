
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  String id;
  bool goalMode;
  int repetition;
  int totalPresses;
  String startTime;
  String endTime;
  bool completed;
  List<dynamic> buttonList;
  String? image;



  Record({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.goalMode,
    required this.completed,
    required this.repetition,
    required this.totalPresses,
    required this.buttonList
  });



  Record.fromJson(Map<String, dynamic> json, String id)
      :
        id = id,
        startTime = json['startTime'],
        endTime = json['endTime'],
        goalMode = json ['goalMode'],
        repetition = json ['repetition'],
        totalPresses = json ['totalPresses'],
        completed = json ['completed'],
        buttonList = json ['buttonList']
  ;

  Map<String, dynamic> toJson() =>
      {
        'startTime' : startTime,
        'endTime' : endTime,
        'goalMode' : goalMode,
        'repetition' : repetition,
        'totalPresses' : totalPresses,
        'completed' : completed,
        'buttonList' : buttonList
      };

}

class RecordModel extends ChangeNotifier{

  final List<Record> items = [];
  final List<Record> completedList = [];

  var wholeBtnPresses = 0;

  CollectionReference recordsCollection = FirebaseFirestore.instance.collection('History');

  bool loading = false;

  RecordModel(){
    fetch();
    filterFetch(true);
  }

  Future add(Record item) async{
    loading = true;
    update();

    await recordsCollection.add(item.toJson());

    await fetch();
  }

  Future delete(String id) async{
    loading =true;
    update();

    await recordsCollection.doc(id).delete();

    await fetch();
  }

  void update() {
    notifyListeners();
  }

  Future updateItem(String id, Record item) async{
    loading = true;
    update();
    await recordsCollection.doc(id).set(item.toJson());
    await fetch();
  }

  Future fetch() async {
    items.clear();
    wholeBtnPresses = 0;
    loading = true;
    notifyListeners();

    var querySnapshot = await recordsCollection.orderBy('startTime').get();

    querySnapshot.docs.forEach((doc) {
      var record = Record.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      var presses = record.totalPresses;
      wholeBtnPresses += presses;
      items.add(record);
    });

    await Future.delayed(Duration(seconds: 1));

    loading = false;
    update();
  }

  //This is a filter list
  Future filterFetch(bool ifCompleted) async {
    completedList.clear();
    loading = true;

    notifyListeners();

    var querySnapshot  = await recordsCollection.orderBy('startTime').get();

    querySnapshot.docs.forEach((doc) {
      var record  = Record.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      if (ifCompleted){
        if(record.completed == true) {
          completedList.add(record);
        }
      } else {
        if (record.completed == false) {
          completedList.add(record);
        }
      }

    });

  }




  Record? get(String? id){
    if(id == null ) return null;
    return items.firstWhere((record) => record.id == id);
  }

}