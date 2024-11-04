import 'package:flutter/material.dart';
import 'package:nasa_/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  Map<String, String>? _imageData;

  @override
  void initState() {
    super.initState();
    _fetchImageData();
  }

  // Fetch the image data (title, explanation, date, image URL)
  Future<void> _fetchImageData() async {
    final imageData = await apiService.fetchImageData();
    setState(() {
      _imageData = imageData;
    });
  }

  // Download the image
  Future<void> _downloadImage() async {
    if (_imageData != null && _imageData!['imageUrl'] != null) {
      // ignore: prefer_const_declarations
      final fileName = "NASA_Space_Image.jpg";
      final path = await apiService.downloadImageToChosenDirectory(
          _imageData!['imageUrl']!, fileName);

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image downloaded to: $path")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NASA APOD")),
      body: _imageData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // title
                  Text(
                    _imageData!['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // date
                  Text(
                    "Date: ${_imageData!['date'] ?? ''}",
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  //  image
                  if (_imageData!['imageUrl'] != null)
                    Image.network(_imageData!['imageUrl']!),
                  const SizedBox(height: 10),
                  //  explanation
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _imageData!['explanation'] ?? '',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _downloadImage,
                    child: const Text("Download Image"),
                  ),
                ],
              ),
            ),
    );
  }
}
