import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AppPage());
  }
}

class AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppPageState();
  }
}

class _AppPageState extends State<AppPage> {
  File pickedImage;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isImageLoaded = false;
  Future pickImageCam() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future pickImageGal() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    final FirebaseVisionImage ourImage =
        FirebaseVisionImage.fromFile(pickedImage);
    final TextRecognizer recognizeText =
        FirebaseVision.instance.textRecognizer();
    final VisionText readText = await recognizeText.processImage(ourImage);
    String phnoPattern = r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$";
    String emailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
    RegExp regExp = RegExp(phnoPattern);
    RegExp regExpemail = RegExp(emailPattern);
    String phno;
    String email;
    String match;
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          match = line.text;
          (regExp.hasMatch(match))
              ? phno = line.text
              : (regExpemail.hasMatch(match))
                  ? email = line.text
                  : print('next');
        }
      }
    }
    if (phno != null || email != null) {
      (phno == null) ? phno = 'Unable to scan' : phno = phno;
      (email == null) ? email = 'Not identified' : email = email;
      Route route =
          MaterialPageRoute(builder: (context) => ContactPage(phno, email));
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.cyanAccent,
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Text(
                        'Snap Phone no. or e-mail For rapid mail or Dial processing'),
                    Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: pickImageCam,
                        iconSize: 50.0,
                      ),
                      FlatButton(
                        child: Text('Gallery'),
                        onPressed: pickImageGal,
                      )
                    ]),
                    RaisedButton(
                      color: Colors.redAccent,
                      child: Text('Read'),
                      onPressed: readText,
                    )
                  ]))
            ])));
  }
}

class ContactPage extends StatelessWidget {
  final String phno;
  final String email;
  ContactPage(this.phno, this.email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scanned detail'),
        ),
        body: Center(
            child: Container(
                child: Column(children: <Widget>[
          Row(children: <Widget>[
            Text(
              phno,
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
                icon: Icon(Icons.call),
                color: Colors.greenAccent,
                onPressed: () async {
                  (await canLaunch("tel:$phno"))
                      ? await launch("tel:$phno")
                      : throw 'Could not launch $phno';
                })
          ]),
          Row(children: <Widget>[
            Text(email),
            IconButton(
                icon: Icon(Icons.mail),
                color: Colors.yellow,
                onPressed: () async {
                  (await canLaunch("tel:$email"))
                      ? await launch("tel:$email")
                      : throw 'Could not launch $email';
                })
          ])
        ]))));
  }
}
