import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Notes(
        //uid: 'bfjkhjshjkdsfhjkdhsfg',
      ),
    );
  }
}

class Notes extends StatefulWidget {
  Notes({this.uid});
  final String uid;
  @override
  _NotesState createState() => _NotesState(uid: uid);
}

class _NotesState extends State<Notes> {

  _NotesState({this.uid});
  final String uid;
  String todoTitle = "";
  createTodos() {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("todos").doc(uid);
    Map<String, String> todos = {"todoTitle": todoTitle,"uid":uid};

    documentReference.set(todos).whenComplete(() => print("Created"));
  }

  deleteTodos(DocumentSnapshot item) {
    FirebaseFirestore.instance.collection('todos').doc(item.id).delete().then((value) => print('Item Deleted'));
  }

  @override
  Widget build(BuildContext context) {
       return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                "NOTES",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      title: Text("Add New Note",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      content: TextField(
                        onChanged: (String value) {
                          todoTitle = value;
                        },
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            createTodos();
                            Navigator.of(context).pop();

                          },
                          child: Text("Add" ,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        FlatButton(
                          onPressed:(){
                            Navigator.of(context).pop();
                            },
                          child:  Text("Cancel",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),)
                      ],
                    );
                  });
            },
            child: Icon(Icons.add, color: Colors.black),
          ),
          body:
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection("todos").snapshots(),
            builder: (context,snapshots){
              if(snapshots.data == null)
                return Center(
                    child: Text("No notes", style: TextStyle(color: Colors.grey),));
              return  ListView.builder(
                  shrinkWrap:true,
                  itemCount: snapshots.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot = snapshots.data.docs[index];
                    return Dismissible(
                        onDismissed: (direction){
                          deleteTodos(documentSnapshot);
                        },
                        key: Key(documentSnapshot["todoTitle"]),
                        child: Card(
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text(documentSnapshot["todoTitle"],style: TextStyle(fontSize: 22.0),),
                            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red,),
                              onPressed: (){
                                // deleteTodos(documentSnapshot["todoTitle"]);
                                deleteTodos(documentSnapshot);
                                final snackBar = SnackBar(
                                  content: Text(' Note Deleted'),);
                                Scaffold.of(context).showSnackBar(snackBar);
                              },
                            ),
                          ),
                        ));
                  });
            },),
    );
  }
}