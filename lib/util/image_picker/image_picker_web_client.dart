import 'dart:typed_data';

import 'package:splitwise_pro/util/image_picker/image_picker_client.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;

class ImagePickerWebClient implements ImagePickerClient {
  @override
  Future<html.File?> pickImage() async {
    return await ImagePickerWeb.getImageAsFile();
  }

  @override
  Future<Uint8List?> pickImageAsBytes() async {
    try {
      final image = await ImagePickerWeb.getImageAsBytes();
      return image;
    } catch (error) {
      print(error);
    }
    return null;
  }
}

ImagePickerClient getImagePickerClient() => ImagePickerWebClient();
