import 'package:flutter/material.dart';
import 'user.dart';
import 'dart:async';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Aplikasi Todo list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  Future<List<User>> users;
  TextEditingController controller = TextEditingController();
  String name;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState(){
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList(){
    setState(() {
        users = dbHelper.getUsers();
    });
  }

  clearName(){
    controller.text = '';
  }

  validate(){
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      if(isUpdating){
        User u = User(curUserId, name);
        dbHelper.update(u);
        setState(() {
          isUpdating = false;
        });
      }else{
        User u = User(null, name);
        dbHelper.save(u);
      }
      clearName();
      refreshList();
    }
  }

  form(){
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Masukkan data anda'),
              validator: (val) => val.length == 0 ? 'Data tidak boleh kosong!' : null,
              onSaved: (val) => name = val,
            ),
            Padding(padding: EdgeInsets.all(10.0),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate,
                  color: Colors.green[500], 
                  child: Text(isUpdating ? 'Actualizar' : 'Submit'),
                  ),
                FlatButton(
                  onPressed: (){
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  color: Colors.red[600], 
                  child: Text('Batal'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<User> users){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Data')),
          DataColumn(label: Text('Hapus')),
        ],
        rows: users.map((user) => DataRow(
          cells: [
          DataCell(
            Text(user.name),
            onTap: (){
              setState(() {
                isUpdating = true;
                curUserId = user.id;
              });
              controller.text = user.name;
            }
          ),
          DataCell(IconButton(
            icon: Icon(Icons.delete_rounded),
            onPressed: (){
              dbHelper.delete(user.id);
              refreshList();
            },
          ))
        ]),).toList(),
      ),
    );
  }

  list(){
    return Expanded(
      child: FutureBuilder(
        future: users,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return dataTable(snapshot.data);
          }
          if(null == snapshot.data || snapshot.data.length == 0){
            return Text("No se ha encontrado Datos");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0,0,0,1)
      ),
      body: new Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
    );
  }
}
