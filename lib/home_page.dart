import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'draggable_card.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'face_detection/face_detector.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

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
  Uint8List? _imageFile;
  bool faceFound = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  // -----------------------------------
  // initState
  // -----------------------------------
  @override
  void initState() {
    clearValues();
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
    InputImage inputImage = InputImage.fromFilePath(pickedImage.path);
    _processImage(inputImage);
    setImagePath = pickedImage.path;
    setState(() {});
  }

  // -----------------------------------
  // build
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black54,
          leading: GestureDetector(
            onTap: () {
              addImage(source: ImageSource.camera);
              clearValues();
            },
            child: Icon(
              Icons.close,
              color: Colors.white70,
            ),
          ),
          actions: [
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
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastLinearToSlowEaseIn,
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
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
          GestureDetector(
            onTap: () {
              addImage(source: ImageSource.camera);
              clearValues();
            },
            child: Row(
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
          ),
          const SizedBox(
            height: 10,
          ),
          !faceFound
              ? const SizedBox.shrink()
              : Row(
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
          !faceFound
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: saveGalleyButton(
                    width: MediaQuery.of(context).size.width,
                    color: eyeList.isEmpty ||
                            mouthList.isEmpty ||
                            eyeList.length < 2
                        ? Colors.white24
                        : Colors.indigo,
                    textColor: Colors.white,
                    title: 'save'.tr,
                    onTap: () async {
                      // if (await Permission.storage.isGranted) {
                      if (eyeList.isNotEmpty &&
                          mouthList.isNotEmpty &&
                          eyeList.length == 2) {
                        _imageFile = await screenshotController.capture();
                        try {
                          if (_imageFile != null) {
                            final result = await ImageGallerySaver.saveImage(
                                _imageFile!,
                                quality: 100,
                                name: _imageFile.hashCode.toString());
                            final result2 = await ImageGallerySaver.saveFile(
                                setImagePath,
                                name: setImagePath.hashCode.toString());

                            toast(text: 'image_downloaded'.tr);
                            debugPrint('result : $result');
                            debugPrint('result : $result2');
                          }
                        } catch (e) {
                          debugPrint('$e');
                        }
                      }
                      // } else {
                      //   await Permission.storage.request();
                      // }
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
  //function to detect face
  // -----------------------------------
  Future<void> _processImage(InputImage? inputImage) async {
    final faces = await _faceDetector.processImage(inputImage!);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
    } else {
      if (faces.isEmpty) {
        toast(text: 'no_face_found'.tr);
      } else if (faces.length > 1) {
        toast(text: 'two_or_more_faces_were_detected'.tr);
      } else {
        faceFound = true;
        setState(() {});
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  // -----------------------------------
  //toast widget
  // -----------------------------------
  toast({required String text}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.indigo,
        textColor: Colors.white,
        fontSize: 16.0);
  }

// -----------------------------------
//clear function
// -----------------------------------
  clearValues() {
    eyeList = [];
    mouthList = [];
    faceFound = false;
    _imageFile = null;
    setImagePath = '';
  }
}
