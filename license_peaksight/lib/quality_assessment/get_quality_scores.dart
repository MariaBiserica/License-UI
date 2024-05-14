import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// class to hold the quality scores
class QualityScores {
  final double? noiseScore, contrastScore, brightnessScore, sharpnessScore, chromaticScore, brisqueScore, ilniqeScore;
  final String? noiseTime, contrastTime, brightnessTime, sharpnessTime, chromaticTime, brisqueTime, ilniqeTime;

  QualityScores({
    this.noiseScore, this.contrastScore, this.brightnessScore, this.sharpnessScore, this.chromaticScore,
    this.brisqueScore, this.ilniqeScore,
    this.noiseTime, this.contrastTime, this.brightnessTime, this.sharpnessTime, this.chromaticTime,
    this.brisqueTime, this.ilniqeTime,
  });

  factory QualityScores.fromJson(Map<String, dynamic> json) {
    return QualityScores(
      noiseScore: _parseDouble(json['noise_score']),
      contrastScore: _parseDouble(json['contrast_score']),
      brightnessScore: _parseDouble(json['brightness_score']),
      sharpnessScore: _parseDouble(json['sharpness_score']),
      chromaticScore: _parseDouble(json['chromatic_score']),
      brisqueScore: _parseDouble(json['brisque_score']),
      ilniqeScore: _parseDouble(json['ilniqe_score']),
      noiseTime: json['noise_time'],
      contrastTime: json['contrast_time'],
      brightnessTime: json['brightness_time'],
      sharpnessTime: json['sharpness_time'],
      chromaticTime: json['chromatic_time'],
      brisqueTime: json['brisque_time'],
      ilniqeTime: json['ilniqe_time'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    }
    throw FormatException('Unable to convert $value to a double');
  }

}

Future<QualityScores?> predictImageQuality(File imageFile, Set<String> selectedMetrics) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/predict'); // Adjust the URI as needed
    var request = http.MultipartRequest('POST', uri)
      ..fields['metrics'] = json.encode(selectedMetrics.toList())
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = json.decode(responseString);
      return QualityScores.fromJson(jsonResponse);  // Use factory constructor to create an instance of QualityScores 
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
  return null; // Return null if there's an error
}
