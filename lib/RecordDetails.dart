import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qlick/Record.dart';
import 'package:share_plus/share_plus.dart';



class RecordDetails extends StatefulWidget {
  const RecordDetails({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {


  String startTime ='';
  Record? record;
  String endTime = '';
  int totalPresses = 0;
  List buttonPressList = [];
  String completed = '';
  int rptDone = 0;
  String id = '';


  // show AlertDialog https://stackoverflow.com/questions/53844052/how-to-make-an-alertdialog-in-flutter
  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel",style: TextStyle(fontSize: 20),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Confirm",style: TextStyle(fontSize: 20),),
      onPressed:  () {
        Provider.of<RecordModel>(context,listen: false).delete(widget.id);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Attention", style: TextStyle(fontSize: 50,color: Colors.red),),
      content: Text("This record will be deleted and can't recover", style: TextStyle(fontSize: 30,color: Colors.amber),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String> getImage() async {
    String? url = await FirebaseStorage.instance.ref("upload/${widget.id}.jpg").getDownloadURL();
    return url;
  }

  //share function



  @override
  Widget build(BuildContext context) {

    var textStyle = TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade200
    );

    record  = Provider.of<RecordModel>(context,listen: false).get(widget.id);
    id = record!.id;
    startTime = record!.startTime;
    endTime = record!.endTime;
    buttonPressList = record!.buttonList;
    completed = record!.completed ? 'completed' : 'incomplete';
    totalPresses = record!.totalPresses;
    rptDone = record!.repetition;
    print ('${widget.id}');



    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Record Details')
            ],
          ),
          //ref: https://stackoverflow.com/questions/57941227/how-to-add-icon-to-appbar-in-flutter
          actions: <Widget>[
            IconButton(onPressed: (){
              Share.share('Attempt id : ${widget.id}, Start time: $startTime, End time: $endTime, Repetitions: $rptDone,  Button list: $buttonPressList');

            }, icon: Icon(
                size: 40,
                color: Colors.white,
                Icons.share
            )),
            IconButton(onPressed: (){
              setState(() {
                showAlertDialog(context);

              });

            }, icon: Icon(
              size: 40,
              Icons.delete,
              color: Colors.white,
            ))
          ],
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    height: 200,
                    child: FutureBuilder(
                      future: getImage(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting){
                            return Container(
                              width: 200,
                              height: 200,
                              child: Center(
                                  child: CircularProgressIndicator()
                                ),
                              );
                            } else if (snapshot.hasData){
                                return Container(
                                    width: 200,
                                    height: 200,
                                    child: Image.network(snapshot.data!,fit: BoxFit.cover,)
                                );
                          } else {
                          return Container(
                            width: 200,
                            height: 200,
                            child: Center(
                                child: Text(
                                  'No Image!',
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                )
                            ),
                          );
                          }
                        }
                    ),
                ),
                Text('Your attempt is $completed',style: textStyle,),
                Text('Start time is $startTime', style: textStyle),
                Text('End Time is $endTime',style: textStyle),
                Text('You have pressed a totoal of $totalPresses buttons',style: textStyle,),
                Text('You have done $rptDone repetitions' , style: textStyle,),
                Divider(thickness: 4,),
                Text('Here is your button list: ' , style: textStyle,),
                SizedBox(height: 50,),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemBuilder: (_, index){
                      var buttonRecord = buttonPressList[index];
                      return ListTile(
                        horizontalTitleGap: 5,

                        title: Center(
                          child: Text(buttonRecord.toString(),style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: Colors.black
                          ),),
                        ),
                      );
                    },
                    itemCount: buttonPressList.length,
                  ),
                ),
              ]
          ),
        )
    );
  }
}
