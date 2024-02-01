import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'draggable_card.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// -----------------------------------
// HomePage
// -----------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


// -----------------------------------
// _HomePageState
// -----------------------------------
class _HomePageState extends State<HomePage> {

  // -----------------------------------
  // Properties
  // -----------------------------------
  ImagePicker imagePicker = ImagePicker();
  String setImagePath = '';
  List<int> eyeList = [];
  List<int> mouthList = [];
  ScreenshotController screenshotController = ScreenshotController();
  GlobalKey _globalKey = GlobalKey();
  Uint8List? _imageFile;


  // -----------------------------------
  // initState
  // -----------------------------------
  @override
  void initState() {
    addImage(source: ImageSource.camera);
    super.initState();
  }





  // -----------------------------------
  // initState
  // -----------------------------------
  Future addImage({
    ImageSource? source,
  }) async {
    final pickImage =
        await imagePicker.pickImage(source: source!, imageQuality: 100);
    if (pickImage == null) return;

    final pickedImage = File(pickImage.path);

    setImagePath = pickedImage.path;
    setState(() {});
  }


  // -----------------------------------
  // build
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black54, actions: [
        Icon(Icons.more_vert, color: Colors.white70),
      ]),
      backgroundColor: Colors.black54,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(
                        File(
                          setImagePath,
                        ),
                      ),
                    ))),
                for (var i = 0; i < eyeList.length; i++) ...{
                  DraggableResizableWidget(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastLinearToSlowEaseIn,
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                              75.0), // Adjust these values as needed
                          topRight: Radius.circular(75.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                    ),
                  )
                },
                for (var i = 0; i < mouthList.length; i++) ...{
                  DraggableResizableWidget(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastLinearToSlowEaseIn,
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                              75.0), // Adjust these values as needed
                          bottomRight: Radius.circular(75.0),
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                    ),
                  )
                }
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              SvgPicture.asset('assets/svgs/ic_back.svg'),
              const SizedBox(
                width: 10,
              ),
              Text(
                "take_a_picture_again".tr,
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),

              /////////Button for Eyes
              saveGalleyButton(
                title: 'eye'.tr,
                onTap: () {
                  eyeList.isEmpty
                      ? eyeList.add(0)
                      : eyeList.length == 1
                          ? eyeList.add(1)
                          : null;
                  setState(() {});
                },
              ),
              const SizedBox(
                width: 10,
              ),
              /////////Button for Mouth
              saveGalleyButton(
                title: 'mouth'.tr,
                onTap: () {
                  mouthList.isEmpty ? mouthList.add(1) : null;
                  setState(() {});
                },
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: saveGalleyButton(
              width: MediaQuery.of(context).size.width,
              color: eyeList.isEmpty || mouthList.isEmpty
                  ? Colors.white24
                  : Colors.indigo,
              textColor: Colors.white,
              title: 'save'.tr,
              onTap: () {
                if (eyeList.isNotEmpty || mouthList.isNotEmpty) {
                  screenshotController.capture().then((Uint8List? image) async {
                    //Capture Done
                    setState(() {
                      _imageFile = image;
                    });
                    // print('_imageFile $_imageFile');

                    String filePath = await saveUint8ListToFile(_imageFile!);

                    await _saveImageToGallery(filePath);
                    _saveImageToGallery(setImagePath);
                  }).catchError((onError) {
                   debugPrint(onError);
                  });
                }
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // -----------------------------------
  // saveGalleyButton
  // -----------------------------------
  GestureDetector saveGalleyButton({
    VoidCallback? onTap,
    String? title,
    double height = 60,
    double width = 60,
    Color color = Colors.white,
    Color textColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(08)),
        child: Center(
          child: Text(
            title!,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }



  // -----------------------------------
  // saveUint8ListToFile
  // -----------------------------------
  Future<String> saveUint8ListToFile(Uint8List data) async {
    Directory? directory = await getTemporaryDirectory();
    if (directory != null) {
      String filePath = '${directory.path}/image.png';
      File file = File(filePath);
      await file.writeAsBytes(data);
      return filePath;
    }
    throw Exception('Failed to get temporary directory');
  }

  // -----------------------------------
  // _saveImageToGallery
  // -----------------------------------
  Future<void> _saveImageToGallery(String filePath) async {
   debugPrint('_saveImageToGallery - $filePath');

    File imageFile = File(filePath);
    Uint8List imageData = await imageFile.readAsBytes();
    final result = await ImageGallerySaver.saveImage(imageData);
    if (result['isSuccess']) {
     debugPrint('Image saved successfully');
    } else {
     debugPrint('Failed to save the image: ${result['errorMessage']}');
     debugPrint('Failed to save the image: ${result}');
    }
    // Utils.toast(result.toString());
  }
}
