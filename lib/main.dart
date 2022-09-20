import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:qlick/Record.dart';
import 'package:qlick/RecordView.dart';
import 'package:qlick/gameSettings.dart';
import 'package:qlick/gameTwoSettings.dart';

const String dataBase = 'History';

Future main() async { //converted main() to be an asynchronous function
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<FirebaseApp> initializeFirebase() async
  {
    if (!Firebase.apps.isNotEmpty) {
      if (kIsWeb) {
        return await Firebase.initializeApp(options: FirebaseOptions(

          //get this information from the firebase console
            apiKey: "GET",
            authDomain: "THIS",
            projectId: "INFORMATION",
            storageBucket: "FROM",
            messagingSenderId: "THE",
            appId: "FIREBASE",
            measurementId: "CONSOLE"
        ));
      }
      else {
        //android and ios get config from the GoogleServices.json and .plist files
        return await Firebase.initializeApp();
      }
    } else {
      return Firebase.app();
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeFirebase(),
        builder: (context,snapshot){
          if (snapshot.hasError){
            return FullScreenText(text: 'Fail to connect to Firebase');
          }
          if (snapshot.connectionState == ConnectionState.done){
            return ChangeNotifierProvider(
                create: (context)=>RecordModel(),
                child:   MaterialApp(
                  title: 'MyApp',
                  theme: ThemeData(
                      primarySwatch: Colors.teal
                  ),
                  home: const MyHomePage(),
                )
            );
          }
          return FullScreenText(text: "Loading");
        },
    );
  }


}

class FullScreenText extends StatelessWidget {
  const FullScreenText({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: Column(children: [Expanded(child: Center(child: Text(text),))],));
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var playerNameController = TextEditingController();

  //widget lifecircle
  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    var buttonStyle = ElevatedButton.styleFrom(
        primary: Colors.teal,
        textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 40,
            fontWeight: FontWeight.bold
        )
    );
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text('Welcom to QLick'),
            ],
          )
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(
                  width: 500,
                  height: 300,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Q',
                          style: TextStyle(
                              fontSize: 100.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade200
                          ),
                        ),
                        Text(
                          'Lick',
                          style: TextStyle(
                              fontSize: 100.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //GAME 1 BUTTON
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    height: 100,
                    child: ElevatedButton(
                        onPressed: (){
                          FocusScope.of(context).unfocus(); // suggested by my friend, not sure the purpose
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context){
                                return GameSettings();
                          }));
                        },
                        style: buttonStyle,
                        child: const Text('Game1')
                    ),
                  ),
                ),
                //GAME 2 BUTTON
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    height: 100,
                    child: ElevatedButton(
                      onPressed: (){
                        FocusScope.of(context).unfocus(); // suggested by my friend, not sure the purpose
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context){
                              return gameTwoSettings();
                            }));
                      },
                      style: buttonStyle,
                      child: const Text('Game2'),
                    ),
                  ),
                ),
                //RECORDS VIEW
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 300,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: (){
                          FocusScope.of(context).unfocus(); // suggested by my friend, not sure the purpose
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context){
                                return Records();
                              }));
                        },
                        style: buttonStyle,
                        child: const Text('History'),
                      )
                  ),
                )
              ]
          ),
        ),
      ),
    );
  }
}
