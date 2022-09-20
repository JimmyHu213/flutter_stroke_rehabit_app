import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qlick/Record.dart';
import 'package:qlick/main.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:share_plus/share_plus.dart';






class Result extends StatefulWidget {
  const Result({Key? key,
    required this.rptDone,
    required this.totalPresses,
    required this.buttonPressList,
    required this.startTime,
    required this.endTime,
    required this.completed}) : super(key: key);


  final int rptDone;
  final int totalPresses;
  final List buttonPressList;
  final String startTime;
  final String endTime;
  final bool completed;

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {

  String startTime ='';
  Record? record;
  String endTime = '';
  int totalPresses = 0;
  List buttonPressList = [];
  String completed = '';
  int rptDone = 0;
  String id = '';
  String imagePath = '';
  String imageLabel = 'No Image!';


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordModel>(
        builder: buildScaffold
    );
  }

  Future<String> getImage() async {
    String? url = await FirebaseStorage.instance.ref("upload/${record!.id}.jpg").getDownloadURL();
    return url;
  }

  void takePicture() async {
    final camera = await availableCameras();

    final firstCamera = camera.first;
    var picture = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: firstCamera))
    );
    print('----------------------$picture');
    if (picture == null) return;
    setState(() {
      imageLabel = 'Loading your image...';
    });

    try {
      await FirebaseStorage.instance
          .ref('upload/${id}.jpg')
          .putFile(File(picture));
    } on FirebaseException catch(e) {
      e.code == 'Error';
    }
    Future.delayed(Duration(seconds: 1));
    setState(() {

    });
  }

  void getFromGallery() async {
    final picture = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
    );
    if (picture == null) return;
    setState(() {
      imageLabel = 'Loading your image...';
    });

    try {
      await FirebaseStorage.instance
          .ref('upload/${id}.jpg')
          .putFile(File(picture!.path));
    } on FirebaseException catch(e) {
      e.code == 'Error';
    }
    Future.delayed(Duration(seconds: 2));
    setState(() {

    });

  }



  Scaffold buildScaffold(BuildContext context, RecordModel recordModel,_) {



    var textStyle = TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade200
    );
    var textStyle2 = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20
    );






    if (recordModel.loading)
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator()
            ],
          ),
        ),
      );

    else
    {
      record = Provider.of<RecordModel>(context,listen: false).items.last;
      id = record!.id;
      startTime = record!.startTime;
      endTime = record!.endTime;
      buttonPressList = record!.buttonList;
      completed = record!.completed ? 'completed' : 'incomplete';
      totalPresses = record!.totalPresses;
      rptDone = record!.repetition;

    }




    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Result')
          ],
        ),
        actions: [
          IconButton(onPressed: (){
            Share.share('Attempt id : ${record!.id}, Start time: $startTime, End time: $endTime, Repetitions: $rptDone,  Button list: $buttonPressList');
          }, icon: Icon(
            Icons.share,
            size: 40,
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
                                  imageLabel,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(onPressed: (){
                        //camera code here
                        takePicture();
                      },
                        child: Text('Camera', style: textStyle2,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(onPressed: (){
                        //gallery code here
                        getFromGallery();


                      }, child: Text('Gallery', style: textStyle2,)),
                    )
                  ],
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
                  height: 250,
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                      onPressed: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                          return MyApp();
                        }));},
                      child: Text(
                        'Back',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold
                        ),
                      )),
                )
              ]
          )
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState()
  {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
// If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
// Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton:
      FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
// Take the Picture in a try / catch block.
          try {
// Ensure that the camera is initialized.
            await _initializeControllerFuture;
// Attempt to take a picture and get the file `image`
// where it was saved.
            final image = await _controller.takePicture();
            print ('--------------${image.path}');

            Navigator.pop(context, image.path);
// Do something with image (next slide)
          } catch (e) {
// If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),

    );
  }
}
