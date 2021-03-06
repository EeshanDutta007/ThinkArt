import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import '../authentication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  CollectionReference ref =
      FirebaseFirestore.instance.collection('TextToImage');
  File _image;
  final picker = ImagePicker();
  String sketch = '';
  String status = '';
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Card(
            elevation: 10,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: h / 2.8,
              width: w / 1.1,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://raw.githubusercontent.com/lucidrains/deep-daze/main/samples/Autumn_1875_Frederic_Edwin_Church.jpg'),
                      fit: BoxFit.fill)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  child: Container(
                    child: Center(
                        child: Text(
                      'Create',
                      style: TextStyle(
                          color: Colors.redAccent,
                          letterSpacing: 2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onPressed: () {
                    var text = '';
                    var image = '';
                    setState(() {
                      status = '';
                    });
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                                Timer.periodic(Duration(seconds: 2), (timer) {
                                  setState(() {});
                                });
                            return Container(
                              color: Color(0xFF737373),
                              height: h * 2.6 / 4,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Center(
                                            child: status == '' ? Text(
                                              'Painting',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ) : Text(
                                              'Loading...',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              height: 200,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image:
                                                          NetworkImage(image),
                                                      fit: BoxFit.fill)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextField(
                                        decoration: InputDecoration(
                                            hintText: 'Enter the Text...'),
                                        onChanged: (value) {
                                          setState(() {
                                            text = value;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      FlatButton(
                                        child: Container(
                                          height: 30,
                                          width: 125,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            color: Colors.redAccent,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Generate Painting',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            status = 'call';
                                          });
                                          ref.doc(text).get().then(
                                              (DocumentSnapshot
                                                  documentSnapshot) {
                                            if (documentSnapshot.exists) {
                                              setState(() {
                                                image =
                                                    documentSnapshot['Image'];
                                                print(image);
                                              });
                                            } else {
                                              ref
                                                  .doc(text)
                                                  .set({
                                                    'Text': text,
                                                    'Image': ''
                                                  })
                                                  .then((value) =>
                                                      print('task Added'))
                                                  .catchError((error) =>
                                                      print('Failed to add'));
                                              print('unsucsessful');
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: 48,
                                      ),
                                      Center(
                                        child: FlatButton(
                                          child: Container(
                                            height: 48,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                border: Border.all(
                                                    width: 2)),
                                            child: Center(
                                              child: Text(
                                                'Order Now!',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                                msg: "Order Confirmed",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 10,
                                                backgroundColor: Colors.black54,
                                                textColor: Colors.white,
                                                fontSize: 13.0);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 48,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        });
                  },
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Card(
            elevation: 10,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: h / 2.8,
              width: w / 1.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                    image: NetworkImage(
                        'https://i.pinimg.com/originals/1f/ba/f0/1fbaf09ad59c6e5721dd194cfa16669e.jpg'),
                    fit: BoxFit.fill),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  child: Container(
                    child: Center(
                        child: Text(
                      'Sketch',
                      style: TextStyle(
                          color: Colors.redAccent,
                          letterSpacing: 2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onPressed: () {
                    setState(() {
                      sketch = '';
                      status = '';
                    });
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            Timer.periodic(Duration(seconds: 2), (timer) {
                              setState(() {});
                            });
                            return Container(
                              color: Color(0xFF737373),
                              height: h * 3/4,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: sketch != '' ? WebView(
                                        initialUrl: 'http://localhost:3333/templates/index.html',
                                        javascriptMode: JavascriptMode.unrestricted,
                                      ) : Container(child: Center(child: status == '' ? Text('Sketch') : Text('Loading...'),),),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera),
                                      title: Text('Camera'),
                                      onTap: getImageViaCamera,
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo),
                                      title: Text('Gallery'),
                                      onTap: getImageViaGallery,
                                    ),
                                    SizedBox(
                                      height: 48,
                                    ),
                                    Center(
                                      child: FlatButton(
                                        child: Container(
                                          height: 48,
                                          width: 200,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(15.0),
                                              border: Border.all(
                                                  width: 2)),
                                          child: Center(
                                            child: Text(
                                              'Order Now!',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg: "Order Confirmed",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 10,
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                              fontSize: 13.0);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 48,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getImageViaCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
          uploadFile(context);
        } else {
          print('No file selected');
        }
      });
    } else {
      print('No file selected');
    }
  }

  Future<void> getImageViaGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
          uploadFile(context);
        } else {
          print('No file selected');
        }
      });
    }
  }

  Future<UploadTask> uploadFile(BuildContext context) async {
    setState(() {
      sketch = '';
      status = 'call';
    });
    String fileName = path.basename(_image.path);
    Reference ref = FirebaseStorage.instance.ref().child(email).child(fileName);
    UploadTask uploadTask = ref.putFile(_image);
    final url1 = await (await uploadTask).ref.getDownloadURL();
    print(url1.toString());

    String display = 'http://localhost:3333/templates/index.html';
    String api = 'http://localhost:5000/?' + 'text=' + url1.toString();
    try {
      print('calling');
      await http.get(api);

      Response response = await http.get(display);
      print('called');
      dom.Document document = parser.parse(response.body);
      setState(() {
        sketch = 'rendered';
      });
    } catch (e) {
      print('error');
    }
    setState(() {
      status = '';
    });
  }
}
