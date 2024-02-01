import 'package:get_storage/get_storage.dart';

import 'package:flutter/material.dart';

import 'app/my_app.dart';


// For saving local storage
final storageBox = GetStorage();

void main()async {
  await GetStorage.init();
  runApp( MyApp());
}

