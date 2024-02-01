import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();
LangController langController = Get.put(LangController());

class LangController extends GetxController {
  void changeLanguage(String param1, String param2) {
    box.write('langCountry', param2);
    box.write('langCode', param1);
    var locate = Locale(param1, param2);
    Get.updateLocale(locate);
  }
}
