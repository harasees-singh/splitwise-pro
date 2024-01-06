import 'dart:io';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/util/image_picker/image_picker_client.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class ImagePicker extends StatefulWidget {
  const ImagePicker({Key? key, required this.onPickImage}) : super(key: key);

  final void Function(Uint8List) onPickImage;

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  Uint8List? _imageBytes;
  final imagePickerClient = ImagePickerClient();

  void _pickImage() {
    try {
      if (kIsWeb) {
        imagePickerClient.pickImageAsBytes().then((imageFile) {
          if (imageFile != null) {
            setState(() {
              _imageBytes = imageFile;
            });
            widget.onPickImage(_imageBytes!);
          }
        });
      } else {
        imagePickerClient.pickImage().then((imageFile) {
          if (imageFile != null) {
            final image = (imageFile as File).readAsBytesSync();
            setState(() {
              _imageBytes = image;
            });
            widget.onPickImage(_imageBytes!);
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: _imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.memory(
                    _imageBytes!,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: frame != null
                            ? child
                            : SizedBox(
                                height: 80,
                                width: 80,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                      );
                    },
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
        Positioned.fill(
          child: Opacity(
            opacity: _imageBytes == null ? 1 : 0,
            child: IconButton(
              icon: Icon(Icons.add_a_photo,
                  color: Theme.of(context).colorScheme.onPrimary),
              onPressed: _pickImage,
            ),
          ),
        )
      ],
    );
  }
}
