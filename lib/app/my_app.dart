import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../home_page.dart';
import '../localization/localization_controller.dart';
import '../localization/localization_model.dart';
import '../main.dart';


// -----------------------------------
// MyApp
// -----------------------------------

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// -----------------------------------
// _MyAppState
// -----------------------------------

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {


  var country = storageBox.read('langCountry') ?? 'KR'; // 'KR'
  var lang = storageBox.read('langCode') ?? 'ko'; // 'Korean'

  // -----------------------------------
  // dispose
  // -----------------------------------
  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  // -----------------------------------
  // initState
  // -----------------------------------
  @override
  void initState() {
    // storageBox.erase();
    WidgetsBinding.instance.addObserver(this);
    langController.changeLanguage(lang.toString(), country.toString());
    super.initState();
  }


  // -----------------------------------
  // build
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return AppAnnotatedRegionWidget(
        child: GetMaterialApp(
          translations: LocalizationModel(),
      title: 'Mimicon',
          fallbackLocale: Locale(country.toString(), lang.toString()),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    ));
  }
}



// -----------------------------------
// AppAnnotatedRegionWidget -> For hiding Keyboard
// -----------------------------------
class AppAnnotatedRegionWidget extends StatelessWidget {
  const AppAnnotatedRegionWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarContrastEnforced: true,
        ),
        child: child,
      ),
    );
  }
}
