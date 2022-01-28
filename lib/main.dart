// ignore_for_file: prefer_const_constructors
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;

  void showdialog(isUpdate, ds) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    String task = "none";
    if (isUpdate) {
      task = ds["task"];
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate ? Text("Update ToDo") : Text("Add ToDo"),
            content: Form(
                key: formkey,
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  initialValue: isUpdate ? ds["task"] : "",
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Task",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Cant be empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    task = value;
                  },
                )),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    if (isUpdate) {
                      db
                          .collection("task")
                          .doc(ds.reference.id)
                          .update({"task": task});
                      Navigator.pop(context);
                    } else {
                      db
                          .collection("task")
                          .add({"task": task, "time": DateTime.now()});
                      Navigator.pop(context);
                    }
                  },
                  child: isUpdate ? Text("Update") : Text("Add"))
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
        title: Text("Crud App"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return Container(
                  child: ListTile(
                    title: Text(ds["task"]),
                    onLongPress: () {
                      db.collection("task").doc(ds.reference.id).delete();
                    },
                    onTap: () {
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
        stream: db.collection("task").orderBy("time").snapshots(),
      ),
    );
  }
}
