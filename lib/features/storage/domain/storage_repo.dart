import 'dart:typed_data';

abstract class StorageRepo {
  // upload profile image in mobile
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // upload profile image in web
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  // upload post image in mobile
  Future<String?> uploadPostImageMobile(String path, String fileName);

  // upload profile image in web
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);
}