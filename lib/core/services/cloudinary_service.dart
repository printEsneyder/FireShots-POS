import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:fireshots_pos/core/constants/cloudinary_constants.dart';

class CloudinaryService {
  Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );
  }

  Future<String?> uploadProductImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConstants.cloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConstants.uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
