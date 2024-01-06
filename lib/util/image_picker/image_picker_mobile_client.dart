import 'dart:io';
import 'dart:typed_data';
import 'package:splitwise_pro/util/image_picker/image_picker_client.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerMobilClient implements ImagePickerClient {
  @override
  Future<File?> pickImage() async {
    final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return imageFile != null ? File(imageFile.path) : null;
  }

  @override
  Future<Uint8List?> pickImageAsBytes() async {
    throw UnimplementedError();
  }
}

ImagePickerClient getImagePickerClient() => ImagePickerMobilClient();