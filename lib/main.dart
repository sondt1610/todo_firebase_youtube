import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      accentColor: Colors.orange,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";
  bool abc = false;

  createTodos() {
    DocumentReference documentReference =
        Firestore.instance.collection("MyTodos").document(input);
    Map<String, String> todos = {"todoTitle": input};
    documentReference
        .setData(todos)
        .whenComplete(() => {print("$input created")});
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        Firestore.instance.collection("MyTodos").document(item);
    Map<String, String> todos = {"todoTitle": item};
    documentReference.delete().whenComplete(() => {print("$item deleted")});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("mytodos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text("Add Todolist"),
                content: TextField(
                  onChanged: (String value) {
                    input = value;
                  },
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      createTodos();
                      Navigator.of(context).pop();
                    },
                    child: Text("Add"),
                  )
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("MyTodos").snapshots(),
          builder: (context, snapshots) {
            print("snapshots");
            print(snapshots.data.documents);
            switch (snapshots.connectionState) {
              case ConnectionState.active:
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshots.data.documents.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      DocumentSnapshot documentSnapshot =
                          snapshots.data.documents[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          deleteTodos(documentSnapshot["todoTitle"]);
                        },
                        key: Key(documentSnapshot["todoTitle"]),
                        child: Card(
                          elevation: 4.0,
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(documentSnapshot["todoTitle"]),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                deleteTodos(documentSnapshot["todoTitle"]);
                              },
                            ),
                          ),
                        ),
                      );
                    });
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    child: Text(
                      "Empty",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              case ConnectionState.none:
              default:
                return Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          }),
    );
  }
}
