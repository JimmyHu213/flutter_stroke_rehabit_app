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

class gameView extends StatefulWidget {
  const gameView({Key? key,

    required this.buttonNum,
    required this.random,
    required this.indication,
    required this.btnSize,
    required this.time,
    required this.repetition,
    required this.rptLimit,
    required this.goalMode}) : super(key: key);

  final int buttonNum;
  final bool random;
  final bool indication;
  final double btnSize;
  final int time ;
  final int repetition;
  final bool rptLimit ;
  final bool goalMode ;



  @override
  State<gameView> createState() => _gameViewState();
}

class _gameViewState extends State<gameView> {

  CollectionReference database = FirebaseFirestore.instance.collection('History');
  String id = '';
  Record? record;
  int timeLeft = 0;
  String hintLabel = 'Now click button 1';
  String repetitionLabel = '';
  String timeLabel = '';
  Timer? timer;
  bool completed = true;
  String gameType = 'Game1';
  int totalPresses = 0;

  double btnSize = 3*25+30;
  int btnNumber = 3;
  int repetition = 3;
  int rptDone = 0;
  bool indication = true;
  bool random = true;
  String startTime = '';
  String endTime = '';
  bool gameMode = true;

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

    //btn size, indication
    btnSize = widget.btnSize*25+30;
    btnNumber = widget.buttonNum;
    indication = widget.indication;
    leftList = getLeftList();
    topList = getTopList();
    indication = widget.indication;
    random = widget.random;
    startTime = timeStamp.format(DateTime.now());
    gameMode = widget.goalMode;


    for (var i=0; i < widget.buttonNum; i++){
      colors.add(Colors.grey);
    }

    if (indication == false){
      hintLabel = '';
    }

    if (widget.goalMode == true){

      if (!widget.rptLimit) {
        timeLeft = widget.time;
        timeLabel = 'Game Time(s): $timeLeft';
        startTimer();
      } else {
        repetition = widget.repetition;
        repetitionLabel = 'Repetion times: ($rptDone/$repetition)';

      }
    } else {
      timeLabel = 'Click Quit to leave';
      repetitionLabel = 'There is not Limit';
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

    if (widget.rptLimit){
      if (rptDone < repetition){
        completed = false;
      }
    } else if (timeLeft > 0 ){
      completed = false;
    }
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
            completed: completed,
          );
        }
    ));
  }

  //ref https://www.youtube.com/watch?v=bjAsnIw3VCs
  void startTimer(){
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0){
          timeLeft--;
          timeLabel = 'Game Time(s): $timeLeft';
        } else {
          stopTimer();
          finishGame();
          pushView();
        }
      });
    });
  }


  void stopTimer(){
    setState(() {
      timer?.cancel();
    });
  }

  List getLeftList() {
    var list = <int>[];
    int random = 0;

    for (var i = 1; i <= widget.buttonNum; i++) {
      var testVaue = Random().nextInt(8);
      random = testVaue*100+25;
      //to avoid overlap, I will put the random to a different range
      while (list.contains(random)) {
        testVaue = Random().nextInt(8);
        random = testVaue*100+25;
      }

      list.add(random);
    }
    return list;
  }

  List getTopList() {
    var list = <int>[];
    var testList = [];
    int random = 0;

    for (var i = 1; i <= widget.buttonNum; i++){
      var testVaue = Random().nextInt(8);
      random = testVaue*100+25;
      //to avoid overlap, I will put the random to a different range
      while (list.contains(random)){
        testVaue = Random().nextInt(8);
        random = testVaue*100+25;
      }
      list.add(random);
    }
    return list;
  }

  void resetButtons() {
    clickdedButton = 1;
    colors = [];
    hintLabel = indication? 'Now click button 1' : '';
    if (random){
      leftList = getLeftList();
      topList = getTopList();
    }

    for (var i=0; i < widget.buttonNum; i++){
      colors.add(Colors.grey);
    }

  }





  @override
  Widget build(BuildContext context) {




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
              //Time Label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(timeLabel, style: textStyle,)
                ],
              ),
              //indication label
              Text(hintLabel,style: TextStyle(color: Colors.amber,fontSize: 40, fontWeight: FontWeight.bold),),
              Divider(thickness: 5,),
              Expanded(
                child: buildButtons(),
              )
            ],
          ),
        ),
      ),
    );
  }

  // use for loop for widgets ref: https://stackoverflow.com/questions/56947046/flutter-for-loop-to-generate-list-of-widgets
  Stack buildButtons (){
    return  Stack(
      children: [
        Container(),
        for (var i = 0; i < widget.buttonNum; i++) generateBtn(leftList[i], topList[i], i+1),
      ],
    );
  }

  Positioned generateBtn(left, int top, int id) {




    return Positioned(
        left: left.toDouble(),
        top: top.toDouble(),
        child: ElevatedButton(
          key: Key(id.toString()),
          onPressed: (){
            setState(() {

              if (gameMode ==true){
                //change the button color
                if (clickdedButton <= widget.buttonNum){

                  if(clickdedButton == id){
                    colors[id-1] = Colors.amber;
                    clickdedButton++;

                    hintLabel = indication? 'Now click button $clickdedButton' : '';
                  }
                  print ('clickdedButton: $clickdedButton');
                }
                //reset the game after each successful repetition
                if (clickdedButton-1 == widget.buttonNum){
                  resetButtons();
                  rptDone++;
                  print('rptDone: $rptDone');

                  if (widget.rptLimit){
                    repetitionLabel = 'Repetion times: ($rptDone/$repetition)';
                    if (rptDone == repetition){
                      finishGame();
                      pushView();

                    }
                  }


                }
              } else {

                if (clickdedButton <= widget.buttonNum){
                  if(clickdedButton == id){
                    colors[id-1] = Colors.amber;
                    clickdedButton++;
                    hintLabel = indication? 'Now click button $clickdedButton': '';
                  }
                  print ('clickdedButton: $clickdedButton');
                }

                if (clickdedButton-1 == widget.buttonNum){
                  resetButtons();
                  rptDone++;
                  print('rptDone: $rptDone');
                }
              }


            });
            btnClicked = { timeStamp.format(DateTime.now()) : id };
            //add to button Pressed list
            buttonPressList.add(btnClicked);
            print(buttonPressList);
          },
          child: Text(id.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: widget.btnSize*3+10),),
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              primary: colors[id-1],
              padding: EdgeInsets.all(20),
              fixedSize: Size(btnSize.toDouble(),btnSize.toDouble())
          ),
        )
    );
  }


}
