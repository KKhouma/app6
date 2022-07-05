import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
  
}

class HomeScreen extends StatelessWidget{
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection('users').snapshots();
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('demo')
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('read',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical:20),
          child: StreamBuilder<QuerySnapshot>(
            stream: users,
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshots,
            ){
              if(snapshots.hasError){
                return Text('something went wrong');
              }
              if(snapshots.connectionState == ConnectionState.waiting){
                return Text('loading');
              }

              final data = snapshots.requireData;

              return ListView.builder(
                itemCount: data.size,
                itemBuilder: (context, index){
                  return Text('Medicine name : ${data.docs[index]['name']} Price in dollar : ${data.docs[index]['price']}');
                },
              );
            },
          )
        ),
        Text('write',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
        MyCustomForm()
      ],
    ),
      ),
  );
  }

}

class MyCustomForm extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
      return MycustomFormState();
  }


}

class MycustomFormState extends State<MyCustomForm>{
  final _formKey = GlobalKey<FormState>();

  var name = '';
  var price = 0;
  
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'enter some product',
              labelText: 'Name',
            ),
            onChanged: (value){
              name = value;
            },
            validator: (value){
              if(value == null || value.isEmpty){
                return 'enter data';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.date_range),
              hintText: 'how much the price',
              labelText: 'price'
            ),
            onChanged: (value){
              price = int.parse(value); 
            },
            validator: (value){
              if(value == null || value.isEmpty){
                return 'enter data';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if(_formKey.currentState!.validate()){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('send data to store')
                    ),
                  );

                  users
                  .add({'name': name, 'price': price})
                  .then((value) => print('data added'))
                  .catchError((error)=>print('failed to add $error'));
                }
              },
              child: Text('submit'),
      ),
      ),
      ],
      )
      );
  }
}