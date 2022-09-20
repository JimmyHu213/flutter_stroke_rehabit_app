import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qlick/gameView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends StatefulWidget {
  const GameSettings({Key? key}) : super(key: key);

  @override
  State<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {

  final playerNameController = TextEditingController();
  final targetValueController = TextEditingController();

  //game parameters need to pass
  var buttonNum = 3;
  var random = true;
  var indication = true;
  var btnSize = 3.0;
  var time = -1;
  var repetition = 3;
  var rptLimit = true;
  var goalMode = true;


  //controller parameters
  var btnSizeHint = 3.0;
  var timeBtnColor = Colors.grey;
  var rptBtnColor = Colors.teal;


  @override
  void initState(){
    super.initState();
    playerNameController.addListener(() {updatePlayerName();});
  }

  //when i use deactive it'll report error
  @override
  void dispose(){
    super.dispose();
    playerNameController.dispose();
  }

  void debugFunc(){
    print ('------------------------');
    print ('Button Numbers: $buttonNum' + ' Random Order: $random' + ' Indication: $indication'
    + ' Button Size: $btnSize' + ' Time: $time' + ' repetition: $repetition' + ' Repetition: $rptLimit'
    + ' Goal Mode: $goalMode');
  }


  //function used to change the color of buttons
  void changeBtnColor(){
    if(rptLimit){
      timeBtnColor = Colors.grey;
      rptBtnColor = Colors.teal;
    } else {
      timeBtnColor = Colors.teal;
      rptBtnColor = Colors.grey;
    }
  }




  //store the playername in a small persistence storage ref:https://pub.dev/packages/shared_preferences
Future<void> updatePlayerName () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("NameKey", playerNameController.text);
}
//get the name that has been stored
Future<void> getPlayerName() async {
    final name = await SharedPreferences.getInstance();
    var playername = name.getString("NameKey") ?? 'Empty';
    playerNameController.text = playername;
}


  @override
  Widget build(BuildContext context) {



    var lableTextStyle = TextStyle(
                                    color: Colors.teal.shade200,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40.0
                                  );



    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text('Game Settings'),
            ],
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 650,
            child:
              Column(
                children: <Widget>[
                  //Welcome Text
                  Text(
                      'Hi Welcome',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade200
                    ),
                  ),
                  //TextField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0,vertical: 20.0),
                    child: FutureBuilder(
                      future: getPlayerName(),
                      builder: (context,snapshot) {
                        return TextField(
                          controller: playerNameController,
                          decoration: const InputDecoration(
                              hintText: "Enter Your Name",
                              labelText: 'Name',
                              border: OutlineInputBorder()
                          ),
                          textAlign: TextAlign.center,
                          maxLength: 15,
                          style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 30
                          ),

                        );
                      }
                    ),
                  ),
                  //Set Text
                  Text(
                      'Let\'s see how you wanna start',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade200
                      ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 800,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          //Button Numbers DropDownMenu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                  'Button Numbers',
                                  style: lableTextStyle,
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: DropdownButton<int>(
                                  //https://stackoverflow.com/questions/49273157/how-to-implement-drop-down-list-in-flutter Set up DropdownBtn
                                    items: <int>[2,3,4,5].map((int num){
                                      return DropdownMenuItem<int>(
                                          value: num,
                                          child: Text(num.toString()),
                                      );
                                    }).toList(),
                                    value: buttonNum,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                    ),
                                    onChanged: (setButtonNum){
                                      setState(() {
                                        buttonNum = setButtonNum as int;
                                        print('buttonNum: $buttonNum');
                                      });
                                    }
                                ),
                              )
                            ],
                          ),
                          //Enable Random Order Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                  'Random Buttons Order',
                                style: lableTextStyle,
                              ),
                              Switch(value: random, onChanged: (value){
                                    setState(() {
                                      random = value;
                                      print('Random Enable $random');
                                    });
                                  }
                              )
                            ],
                          ),
                          //Enable Indication Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                'Indication',
                                style: lableTextStyle,
                              ),
                              Switch(value: indication, onChanged: (value){
                                setState(() {
                                  indication = value;
                                  print('Indication Enable $indication');
                                });
                              })

                            ],
                          ),
                          //Button Size Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text('Button Size',
                              style: lableTextStyle,
                              ),
                              Text(btnSizeHint.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                  color: Colors.black
                                ),
                              ),
                              Slider(
                                  value: btnSize,
                                  max: 5.0,
                                  min: 1.0,
                                  divisions: 4,
                                  onChanged: (value){
                                setState(() {
                                  btnSize = value;
                                  btnSizeHint = value;
                                  print('Button Size: $btnSize');
                                });
                              })
                            ],
                          ),
                          //Goal and Time set
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    rptLimit = false;
                                    time = int.parse(targetValueController.text);
                                    repetition = -1;
                                    changeBtnColor();
                                  });
                                  debugFunc();
                                },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                    padding:const EdgeInsets.symmetric(horizontal: 16),
                                    primary: timeBtnColor,

                                  ),

                                  child: const Text('Time Limit(s)'),
                              ),
                              ElevatedButton(

                                  onPressed: (){
                                    setState(() {
                                      rptLimit = true;
                                      repetition = int.parse(targetValueController.text);
                                      time = -1;
                                      changeBtnColor();
                                    });
                                    debugFunc();
                                  },
                                  child: Text(
                                    'Repetition',
                                  ),
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                  padding:const EdgeInsets.symmetric(horizontal: 16),
                                  primary: rptBtnColor,
                                ),
                              ),
                              SizedBox(
                                height: 80,
                                width: 100,
                                child: TextField(
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-99]'))],
                                  controller: targetValueController,
                                  decoration: const InputDecoration(
                                    hintText: '3',
                                    border: OutlineInputBorder(),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLength: 2,
                                  onChanged: (value){
                                    setState(() {
                                      if (rptLimit == true){
                                        repetition = int.parse(targetValueController.text);
                                      } else {
                                        time = int.parse(targetValueController.text);
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                          //Mode button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      goalMode = true;
                                    });
                                    debugFunc();
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return gameView(
                                          buttonNum: buttonNum,
                                          random: random,
                                          indication: indication,
                                          btnSize: btnSize,
                                          time: time,
                                          repetition: repetition,
                                          rptLimit: rptLimit,
                                          goalMode: goalMode
                                      );
                                    })
                                    );
                                  },
                                  child: Text('Goal Mode'),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(15.0),
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40.0
                                    ),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      goalMode = false;
                                    });
                                    debugFunc();
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                     return gameView(
                                         buttonNum: buttonNum,
                                         random: random,
                                         indication: indication,
                                         btnSize: btnSize,
                                         time: time,
                                         repetition: repetition,
                                         rptLimit: rptLimit,
                                         goalMode: goalMode
                                     );
                                    })
                                    );
                                  },
                                  child: Text('Free Play'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(15.0),
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40.0
                                  ),
                                ),
                              )
                            ],
                          )


                        ],
                      ),
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}
