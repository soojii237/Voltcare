// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

 pickImage(
    {required BuildContext context, required bool isCamera,}) async {
  String? path;

  await ImageHandler.pickImageFromGallery(isCamera: isCamera)
      .then((pickedFile) async {
    if (pickedFile == null) {
      return {'status':false,'path':null,'message':'Invalid'};
    }

    var file = File(pickedFile.path);
    path = file.path;
    if (file.lengthSync() > 5000000) {
     return {'status':false,'path':null,'message':'Image size exceeds maximum of 5MB'};
    }


    
  }).onError((error, stackTrace) {
     return {'status':false,'path':null,'message':'Error'};
  });
   return {'status':true,'path':path,'message':'Invalid'};
}

class ImageHandler {
  /// Open image gallery and pick an image
  static Future<XFile?> pickImageFromGallery({required bool isCamera}) async {
    debugPrint("....................................$isCamera");

    return await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxHeight: 1080,
        maxWidth: 1080);
  }

}
