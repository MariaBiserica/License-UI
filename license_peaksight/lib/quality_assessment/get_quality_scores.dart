import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// class to hold the quality scores
class QualityScores {
  final double? noiseScore;
  final double? contrastScore;
  final double? brightnessScore;
  final double? sharpnessScore;
  final double? chromaticScore;

  QualityScores({
    this.noiseScore, 
    this.contrastScore,
    this.brightnessScore,
    this.sharpnessScore,
    this.chromaticScore,
  });
}

Future<QualityScores> predictImageQuality(File imageFile, Set<String> selectedMetrics) async {
  var uri = Uri.parse('http://127.0.0.1:5000/predict'); // Adjust the URI as needed
  var request = http.MultipartRequest('POST', uri)
    ..fields['metrics'] = json.encode(selectedMetrics.toList())
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  
  print("Sending request to server...");
  var response = await request.send().timeout(Duration(seconds: 30));
  print("Received response from server");

  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var jsonResponse = json.decode(responseString);
    return QualityScores(
      noiseScore: selectedMetrics.contains('Noise') ? jsonResponse['noise_score']?.toDouble() : null,
      contrastScore: selectedMetrics.contains('Contrast') ? jsonResponse['contrast_score']?.toDouble() : null,
      brightnessScore: selectedMetrics.contains('Brightness') ? jsonResponse['brightness_score']?.toDouble() : null,
      sharpnessScore: selectedMetrics.contains('Sharpness') ? jsonResponse['sharpness_score']?.toDouble() : null,
      chromaticScore: selectedMetrics.contains('Chromatic Quality') ? jsonResponse['chromatic_score']?.toDouble() : null,
    );
  } else {
    throw Exception('Failed to load quality scores');
  }
}
