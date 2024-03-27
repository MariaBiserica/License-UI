import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<double> predictImageQuality(File imageFile) async {
  var uri = Uri.parse('http://127.0.0.1:5000/predict'); // Adjust the URI as needed
  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  print("Sending request to server...");
  var response = await request.send().timeout(Duration(seconds: 30));
  print("Received response from server");
  // var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var jsonResponse = json.decode(responseString);
    return jsonResponse['quality_score'];
  } else {
    throw Exception('Failed to load quality score');
  }
}
