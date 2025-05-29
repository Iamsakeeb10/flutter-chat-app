import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? selectedImage;

  void _imagePickerHandler() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.5),
          foregroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : null,
        ),
        TextButton.icon(
          onPressed: _imagePickerHandler,
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          icon: Icon(Icons.camera),
          style: TextButton.styleFrom(
            iconColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
