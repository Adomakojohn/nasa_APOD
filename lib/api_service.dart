// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class ApiService {
  final String _apiKey = 'uhfqNGflSLeNzDOmJTOxSEqZNS530uIzIpNfSWne';

  // Fetch image data (URL, title, explanation, date) from NASA API
  Future<Map<String, String>?> fetchImageData() async {
    final url = 'https://api.nasa.gov/planetary/apod?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract necessary fields and return them in a map
        return {
          'title': data['title'],
          'explanation': data['explanation'],
          'date': data['date'],
          'imageUrl': data['url'],
        };
      } else {
        print(
            "Failed to fetch image data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  // Request storage permission from the user
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  //  pick a specific directory to save the image
  Future<String?> pickSaveDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      print("Directory selected: $directoryPath");
    }
    return directoryPath;
  }

  // Download the image to directory
  
  Future<String?> downloadImageToChosenDirectory(
      String imageUrl, String fileName) async {
        //ask permision
    if (!await requestStoragePermission()) {
      print("Storage permission denied.");
      return null;
    }
       //let user pick directory
    final saveDirectory = await pickSaveDirectory();
    if (saveDirectory == null) {
      print("No directory chosen.");
      return null;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        //create a file with the directory name and filename 
        final filePath = '$saveDirectory/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("Image downloaded to: $filePath");
        return filePath;
      } else {
        print("Failed to download image. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error downloading image: $e");
      return null;
    }
  }
}
