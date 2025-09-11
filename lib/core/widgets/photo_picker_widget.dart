import 'dart:io';

import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerWidget extends StatefulWidget {
  const PhotoPickerWidget({super.key});

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  List<File> selectedPhotos = [];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showPhotoSourceDialog,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_alt, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  selectedPhotos.isEmpty ? S.of(context).add_photo : S.of(context).photo_selected,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        if (selectedPhotos.isNotEmpty)
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Image.file(selectedPhotos[index], width: 50, height: 50, fit: BoxFit.cover);
              },
            ),
          ),
      ],
    );
  }

  void _showPhotoSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).add_new_photo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(S.of(context).take_a_picture),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).choose_from_gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      if (source == ImageSource.camera) {
        final photo = await picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          setState(() => selectedPhotos.add(File(photo.path)));
        }
      } else {
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() => selectedPhotos.addAll(pickedFiles.map((e) => File(e.path))));
        }
      }
    } catch (e) {
      if (kDebugMode) print('${S.of(context).error_photo} $e');
    }
  }
}
