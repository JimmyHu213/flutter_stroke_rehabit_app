import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qlick/Record.dart';
import 'package:qlick/gameSettings.dart';
import 'package:qlick/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qlick/resultView.dart';

class gameTwoView extends StatefulWidget {
  const gameTwoView({Key? key, this.btnSize, this.indication,

   }) : super(key: key);


  final btnSize;
  final indication;


  @override
  State<gameTwoView> createState() => _gameTwoViewState();
}

class _gameTwoViewState extends State<gameTwoView> {

  CollectionReference database = FirebaseFirestore.instance.collection('History');
  String id = '';
  Record? record;
  int timeLeft = 0;
  String hintLabel = 'Drag Button 1 to Button 2';
  String repetitionLabel = '';
  String timeLabel = '';
  Timer? timer;
  bool completed = true;
  String gameType = 'Game1';
  int totalPresses = 0;

  double btnSize = 3*25+30;
  int btnNumber = 2;
  int repetition = 3;
  int rptDone = 0;
  bool indication = true;
  bool random = true;
  String startTime = '';
  String endTime = '';
  bool gameMode = true;
  double left1 = 0;
  double top1 = 0;
  double left2 = 0;
  double top2 = 0;

  List leftList = [];
  List topList = [];
  List<Map<String, int>> buttonPressList = [];

  DateFormat timeStamp =DateFormat("dd/MM/yyyy HH:mm:ss");
  Map<String, int> btnClicked = {};

  //for buttons parameters
  var clickdedButton = 1;
  List<Color> colors = [];




  @override
  void initState(){
    super.initState();

    initGame();

  }

  void dispose(){
    super.dispose();
  }

  //func to preset the game
  void initGame(){
    print('Initial the game');
    leftList = getLeftList();
    topList = getTopList();

    //btn size, indication
    btnSize = widget.btnSize*25+30;
    indication = widget.indication;
    startTime = timeStamp.format(DateTime.now());

    if (indication == false){
      hintLabel = '';
    }

  }



  void debug(){
    print('----------------------');
    print('Start time: $startTime'+ ' End Time: $endTime'
        + ' Repetition: $rptDone' + ' Button List: $buttonPressList'
        + ' Game Type: $gameType' + ' if completed: $completed');

  }

  void finishGame() async{
    print ('Game is over');
    endTime = timeStamp.format(DateTime.now());
    totalPresses = buttonPressList.length;

    debug();

    record = Record(id: '',
        startTime: startTime,
        endTime: endTime,
        goalMode: gameMode,
        completed: completed,
        repetition: rptDone,
        totalPresses: totalPresses,
        buttonList: buttonPressList
    );

    await Provider.of<RecordModel>(context,listen: false).add(record!)
        .then((value) => print('-------------Record added Successfully'))
        .catchError(()=> print('-------------Fail upload'));

  }

  void pushView() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context){
          return Result(
            rptDone: rptDone,
            totalPresses: totalPresses,
            buttonPressList: buttonPressList,
            startTime: startTime,
            endTime: endTime,
            completed: true,
          );
        }
    ));
  }






  List getLeftList() {
    var list = <double>[];
    double random = 0;

    for (var i = 1; i <= 2; i++) {
      var testVaue = Random().nextInt(8);
      random = testVaue*100+25;
      //to avoid overlap, I will put the random to a different range
      while (list.contains(random)) {
        testVaue = Random().nextInt(8);
        random = testVaue*100+25;
      }

      list.add(random);
    }
    print(list);
    return list;
  }

  List getTopList() {
    var list = <double>[];
    double random = 0;

    for (var i = 1; i <= 2; i++){
      var testVaue = Random().nextInt(8);
      random = testVaue*100+25;
      //to avoid overlap, I will put the random to a different range
      while (list.contains(random)){
        testVaue = Random().nextInt(8);
        random = testVaue*100+25;
      }
      list.add(random);
    }
    print(list);
    return list;
  }

  void resetButtons() {

    leftList = getLeftList();
    topList = getTopList();


  }





  @override
  Widget build(BuildContext context) {


    left1 = leftList[0];
    top1 = topList[0];

    left2 = leftList[1];
    top2 = topList[1];

    var textStyle = TextStyle(
        color: Colors.teal,
        fontWeight: FontWeight.bold,
        fontSize: 40
    );




    return Scaffold(
      appBar: AppBar(
        //use navigator.pushreplacement later ref https://www.flutterbeads.com/remove-back-button-on-appbar-in-flutter/
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('QLick'),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //quit button
              SizedBox(
                height: 50 ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Click the Buttons ASAP!',style: TextStyle(color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                    ElevatedButton(
                      onPressed: (){
                        print('Quit');
                        finishGame();
                        pushView();
                      },
                      child: Text('    Quit   '),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          primary: Colors.teal,
                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                      ),
                    ),
                  ],
                ),
              ),
              //Repetion label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(repetitionLabel, style: textStyle,),
                ],
              ),
              //indication label
              Text(hintLabel,style: TextStyle(color: Colors.amber,fontSize: 40, fontWeight: FontWeight.bold),),
              Divider(thickness: 5,),
              Expanded(
                  child: buildStack()
              )

            ],
          ),
        ),
      ),
    );
  }

  Stack buildStack() {
    return Stack(
      children: [
        Container(),
        Positioned(
          left: left1,
          top: top1,
          child: Draggable<int>(
          data: 1,
            feedback: elevatedButton1(1, Colors.amber),
            child: elevatedButton1(1, Colors.amber),
            childWhenDragging: elevatedButton1(1, Colors.grey),
          )
        ),
        Positioned(
            left: left2,
            top: top2,
            child: DragTarget<int>(
                    builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                      ) {
                          return Container(
                            child: Center(
                                child: elevatedButton2(2, Colors.pink),
                            ),
                        );
                      },
                      onWillAccept: (data){
                          return data == 1;
                      },
                      onAccept: (data){
                        setState(() {

                          rptDone++;
                          totalPresses++;
                          completed = true;
                          btnClicked = { timeStamp.format(DateTime.now()) : 1 };
                          buttonPressList.add(btnClicked);
                          resetButtons();
                          print ('done $rptDone');
                        });
                      },
            )

        )
      ],

    );
  }


  ElevatedButton elevatedButton1(int id, Color color) {
    return ElevatedButton(
          key: Key(id.toString()),
          onPressed: (){
            setState(() {

            });
          },
          child: Text(id.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: widget.btnSize*3+10),),
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              primary: color,
              padding: EdgeInsets.all(20),
              fixedSize: Size(btnSize.toDouble(),btnSize.toDouble())
          ),
        );
  }

  ElevatedButton elevatedButton2(int id, Color color) {
    return ElevatedButton(
      key: Key(id.toString()),
      onPressed: (){
        setState(() {

        });
      },
      child: Text(id.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: widget.btnSize*3+10),),
      style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: color,
          padding: EdgeInsets.all(20),
          fixedSize: Size(btnSize.toDouble(),btnSize.toDouble())
      ),
    );
  }

  // use for loop for widgets ref: https://stackoverflow.com/questions/56947046/flutter-for-loop-to-generate-list-of-widget




}
