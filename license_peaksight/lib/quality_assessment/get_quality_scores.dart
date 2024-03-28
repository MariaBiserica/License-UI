import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// class to hold the quality scores
class QualityScores {
  final double noiseScore;
  final double contrastScore;
  final double brightnessScore;
  final double sharpnessScore;
  final double chromaticScore;

  QualityScores({
    required this.noiseScore, 
    required this.contrastScore,
    required this.brightnessScore,
    required this.sharpnessScore,
    required this.chromaticScore,
  });
}

Future<QualityScores> predictImageQuality(File imageFile) async {
  var uri = Uri.parse('http://127.0.0.1:5000/predict'); // Adjust the URI as needed
  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  print("Sending request to server...");
  var response = await request.send().timeout(Duration(seconds: 30));
  print("Received response from server");

  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var jsonResponse = json.decode(responseString);
    return QualityScores(
      noiseScore: jsonResponse['noise_score'],
      contrastScore: jsonResponse['contrast_score'],
      brightnessScore: jsonResponse['brightness_score'],
      sharpnessScore: jsonResponse['sharpness_score'],
      chromaticScore: jsonResponse['chromatic_score'],
    );
  } else {
    throw Exception('Failed to load quality scores');
  }
}
