import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final url = 'https://datingapp-oz22.onrender.com/api/auth/register';
  
  try {
    print('Reading valid image from assets...');
    final imageFile = File('assets/images/bummps-icon.png');
    if (!await imageFile.exists()) {
      print('Error: assets/images/bummps-icon.png does not exist.');
      return;
    }
    
    final imageBytes = await imageFile.readAsBytes();
    print('Image read successfully (${imageBytes.length} bytes).');
    
    print('Sending multipart registration request with valid image...');
    final randomInt = Random().nextInt(100000);
    
    final multipartFile = MultipartFile.fromBytes(
      imageBytes,
      filename: 'bummps-icon.png',
    );
    
    final formData = FormData.fromMap({
      'name': 'Alexander Sterling',
      'email': 'alexander$randomInt@luxury.com',
      'password': 'password123',
      'profilePicture': multipartFile,
    });
    
    final response = await dio.post(url, data: formData);
    print('Response status: ${response.statusCode}');
    print('Response status: ${response.statusCode}');
    print('Response status: ${response.statusCode}');
    print('sdfdf status: ${response.statusCode}');
    print('dsfdf: ${response.statusCode}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');
  } on DioException catch (e) {
    print('Error response status: ${e.response?.statusCode}');
    print('Error response body: ${e.response?.data}');
  } catch (e) {
    print('Generic error: $e');
  }
}
