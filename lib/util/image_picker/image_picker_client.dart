import 'dart:typed_data';

import 'package:splitwise_pro/util/image_picker/image_picker_stub.dart'
if (dart.library.io) 'package:splitwise_pro/util/image_picker/image_picker_mobile_client.dart'
if (dart.library.html) 'package:splitwise_pro/util/image_picker/image_picker_web_client.dart';

abstract class ImagePickerClient {
  Future<Object?> pickImage();
  Future<Uint8List?> pickImageAsBytes();
  factory ImagePickerClient() => getImagePickerClient();
}
