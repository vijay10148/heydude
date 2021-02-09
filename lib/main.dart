import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        accentColor: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home:  homepage(),
    );
  }
}

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final db = Firestore.instance;
  String task;

  void showdialog(bool isUpdate, DocumentSnapshot ds) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate
                ? Text('Update your Reminder')
                : Text('Add your Reminder'),
            content: Form(
              key: formkey,
              autovalidate: true,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "waiting for your input ",
                ),
                validator: (_val) {
                  if (_val.isEmpty) {
                    return "can't be Empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (_val) {
                  task = _val;
                },
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  if (isUpdate) {
                    db
                        .collection('tasks')
                        .document(ds.documentID)
                        .updateData({'task': task, 'time': DateTime.now()});
                  } else {
                    db
                        .collection('tasks')
                        .add({'task': task, 'time': DateTime.now()});
                  }
                  Navigator.pop(context);
                },
                child: Text("add"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showdialog(false, null),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Hey Dude'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('tasks').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                return Container(
                  child: ListTile(
                    title: Text(ds['task'],
                    style: TextStyle(decoration: TextDecoration.none,
                    fontFamily: 'Lemonada',
                    fontWeight: FontWeight.w500),
                    ),
                    onLongPress: () {
                      //delete
                      db.collection('tasks').document(ds.documentID).delete();
                    },
                    onTap: () {
                      //update
                      showdialog(true, ds);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return CircularProgressIndicator();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
