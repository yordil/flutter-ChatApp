import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:uuid/uuid.dart';

class S3Uploader {
  static const String _accessKey = "AKIAWYFSGW7O5UZRZXJA";
  static const String _secretKey = "hzjIushyH67hL5MisVf4N6xztxGnM7KusCRr5V4";
  static const String _bucketName = "socialpulseyordi";
  static const String _region = "eu-north-1";
  static const String _baseUrl =
      "https://socialpulseyordi.s3.eu-north-1.amazonaws.com/";

  /// Generate a random filename using UUID.
  static String generateFileName(String extension) {
    final uuid = Uuid();
    return "${uuid.v4()}.$extension";
  }

  /// Upload a file (mobile/desktop platforms) to S3.
  static Future<String> uploadFile(File file) async {
    try {
      final String fileName = generateFileName(file.path.split('.').last);

      final String? fileUrl = await AwsS3.uploadFile(
        accessKey: _accessKey,
        secretKey: _secretKey,
        file: file,
        bucket: _bucketName,
        region: _region,
      );

      return "$_baseUrl$fileName";
    } catch (e) {
      print("Error uploading file to S3: $e");
      throw Exception("Failed to upload file.");
    }
  }

  /// Upload file bytes (for web platforms) to S3.
  static Future<String> uploadFileBytes(
      Uint8List fileBytes, String extension) async {
    try {
      final String fileName = generateFileName(extension);
      final String uploadUrl = "$_baseUrl$fileName";

      final response = await http.put(
        Uri.parse(uploadUrl),
        body: fileBytes,
        headers: {
          "Content-Type": "application/octet-stream",
          "x-amz-acl": "public-read",
        },
      );

      if (response.statusCode == 200) {
        return uploadUrl;
      } else {
        throw Exception(
            "Failed to upload file. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading file bytes to S3: $e");
      throw Exception("Failed to upload file bytes.");
    }
  }
}
