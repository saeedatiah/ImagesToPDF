import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image = [];
  late FToast fToast;
  TextEditingController textEditingController=TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("image to pdf"),
        actions: [
          IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () {
                showDialog(
                    context: context, builder:(_) {
                      return AlertDialog(
                        title: Text('حفظ الملف بأسم '),
                        content: TextField(
                          controller:textEditingController ,
                        ),
                        actions: [
                          ElevatedButton(onPressed: ()
                              {
                                if(textEditingController.text!='')
                                  {
                                    createPDF();
                                    savePDF();
                                    Navigator.pop(context);
                                  }
                                else
                                  _showToast('حقل الاسم فارغ', false);
                              },
                              child: Text('حفظ')
                          ),
                          ElevatedButton(onPressed: ()
                              {
                                Navigator.pop(context);
                              },
                              child: Text('الغاء')
                          ),

                        ],
                      );}
                      );
                }
                ),


          IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                _image = [];
                setState(() {
                });
              }),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: getImageFromGallery,
      ),
      body: _image != null
          ? ListView.builder(
        itemCount: _image.length,
        itemBuilder: (context, index) =>
            Container(
                height: 400,
                width: double.infinity,
                margin: EdgeInsets.all(8),
                child: Image.file(
                  _image[index],
                  fit: BoxFit.cover,
                )),
      )
          : Container(),
    );
  }
  getImageFromGallery() async {
//    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile2 = await picker.pickMultiImage();
    //final pickedFile23 = await picker.;
    setState(() {
      if (pickedFile2 != null) {
        for(var file in pickedFile2)
        {
          _image.add(File(file.path));
        }
      } else {
        print('No image selected');
      }
    });
  }

  createPDF() async {
    for (var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Center(child: pw.Image(image));
          }));
    }
  }

  savePDF() async {
    try {
      var aa=pdf;
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/${textEditingController.text}.pdf');
      await file.writeAsBytes(await pdf.save());
      print('success saved to documents');
      _showToast('تم الحفظ بنجاح',true);
     // showPrintedMessage('success', 'saved to documents');
    } catch (e) {
      print('error ${e.toString()}');
      _showToast( e.toString(),false);
      // showPrintedMessage('error', e.toString());
    }
  }

  _showToast(String msg,bool success) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: success? Colors.greenAccent :Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon( success? Icons.check :Icons.clear ),
          SizedBox(
            width: 12.0,
          ),
          Text(msg),
        ],
      ),
    );


    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    // Custom Toast Position
//    fToast.showToast(
//        child: toast,
//        toastDuration: Duration(seconds: 2),
//        positionedToastBuilder: (context, child) {
//          return Positioned(
//            child: child,
//            top: 16.0,
//            left: 16.0,
//          );
//        });
  }
}
