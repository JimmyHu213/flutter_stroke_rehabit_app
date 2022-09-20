import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qlick/RecordDetails.dart';
import 'package:share_plus/share_plus.dart';
import 'Record.dart';

class Records extends StatefulWidget {
  const Records({Key? key}) : super(key: key);

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {

  String shareString = '';
  final searchFieldController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Consumer<RecordModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, RecordModel recordModel, _) {
    
    Record record;



    return Scaffold (
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('Records'),
          ],
        ),
        actions: <Widget>[
          IconButton(onPressed: (){
            Share.share(shareString);

          }, icon: Icon(
              size: 40,
              color: Colors.white,
              Icons.share
          ))
        ],
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (recordModel.loading) CircularProgressIndicator() else
                SizedBox(
                  height: 600,
                  child: ListView.builder(
                    itemBuilder: (_, index){

                      record = recordModel.items[index];

                      var type = record.goalMode ? 'Goal Mode' : 'Free Mode';
                      shareString += 'Start time: ${record.startTime}, End time: ${record.endTime}, Repetitions: ${record.repetition}, Button List: ${record.buttonList}';

                      return ListTile(
                        title: Text(
                          'Attempt: ${index+1}' + ' $type',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.amber
                          ),
                        ),
                        subtitle: Text('Start time: '+ record.startTime + '  End time: ' + record.endTime +
                            ' Repetition: ' + record.repetition.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                        ),
                        leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: Container(
                                color: Colors.grey,
                              child: record.goalMode ?
                              Center(child: Text('G',style: TextStyle(fontSize: 30),)) : Center(child: Text('F',style: TextStyle(fontSize: 30))),
                            )
                        ),
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(
                              builder: (context){
                                return RecordDetails(id: record.id);
                              })
                          );
                        },
                      );
                    },

                    itemCount: recordModel.items.length,
                  ),
                ),
              SizedBox(
                height: 100,
                // child: Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: <Widget>[
                //       ElevatedButton(
                //           onPressed: () async {
                //             await recordModel.filterFetch(true);
                //           },
                //           child: Text('Completed Games')),
                //       ElevatedButton(
                //           onPressed: () async {
                //
                //           },
                //           child: Text('Incompleted Games')),
                //       ElevatedButton(
                //         child: Text('Clear'),
                //         onPressed: () async {
                //
                //         },
                //       ),
                //     ],
                //   ),
                // ),
              ),

              SizedBox(
                height: 200,
                width: 600,
                child: Text('You have clicked ${recordModel.wholeBtnPresses} buttons and completed ${recordModel.items.length} attempts',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.black
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
