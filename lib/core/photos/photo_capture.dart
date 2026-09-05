import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, library }

/// Gets a photo from the user; returns the captured file's path, or null
/// when they backed out. Tests inject a fake.
abstract class PhotoCapture {
  Future<String?> capture(PhotoSource source);
}

class ImagePickerCapture implements PhotoCapture {
  final _picker = ImagePicker();

  @override
  Future<String?> capture(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        PhotoSource.camera => ImageSource.camera,
        PhotoSource.library => ImageSource.gallery,
      },
      // A souvenir on a shelf doesn't need a 12 MP original.
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    return file?.path;
  }
}
