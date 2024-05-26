import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

Future<String?> modifyImageSplineRequest(String imagePath, List<Map<String, int>> controlPoints) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/modify-image-spline'); // Adjust the URI as needed
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath))
      ..fields['control_points'] = controlPoints.map((point) => '${point['x']},${point['y']}').join(';');

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_modified_${DateTime.now().millisecondsSinceEpoch}.jpg';
      var file = File(filePath);
      await file.writeAsBytes(responseData);
      return filePath;
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
  return null; // Return null if there's an error
}
