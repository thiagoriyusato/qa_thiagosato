import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBMUJzVVPmxpt7o59kvxL3NQrGihYqQFBg",
  authDomain: "banco-qa.firebaseapp.com",
  projectId: "banco-qa",
  storageBucket: "banco-qa.appspot.com",
  messagingSenderId: "301269498454",
  appId: "1:301269498454:web:e2b25053e835ee5fc219f7"
);

void main() async {
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override

  
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _textEditingController = TextEditingController();
  List<String> _texts = [];
  int _likesCount = 0;

  void _addText() {
    String text = _textEditingController.text;
    if (text.isNotEmpty) {
      setState(() {
        _texts.add(text);
        firestore.collection('questions1').add(
          {
            'description': _textEditingController.text,
            'likes': _likesCount,
            'user': "Anônimo",
            'timecreated': FieldValue.serverTimestamp()
          });
      });
    }
    _textEditingController.clear();
  }

  void _likeText(int index) {
    setState(() {
      _likesCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar ListTile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Faça sua pergunta...',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Text('Enviar como anônimo'),
                          ),
                          ElevatedButton(
                            onPressed: _addText,
                            child: Text('Enviar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('questions1').orderBy('timecreated').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
              var questions = snapshot.data!.docs
                  as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

              return ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  var question = questions[index];
                  return Card(
                    child: ListTile(
                      title: Text(question['description']),
                      subtitle: Text('Likes: ${question['likes']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          setState(() {
                            questions[index].reference.update({
                              'likes': question['likes'] + 1,
                            });
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  ),
);
}
}