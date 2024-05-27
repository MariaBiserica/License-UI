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

Future<String?> applyGaussianBlur(String imagePath) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/apply_gaussian_blur');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_blurred_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

Future<String?> applyEdgeDetection(String imagePath) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/apply_edge_detection');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_edges_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

Future<String?> applyColorSpaceConversion(String imagePath) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/apply_color_space_conversion');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_converted_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

Future<String?> applyHistogramEqualization(String imagePath) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/apply_histogram_equalization');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_equalized_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

Future<String?> applyImageRotation(String imagePath, double angle) async {
  try {
    var uri = Uri.parse('http://127.0.0.1:5000/apply_image_rotation');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath))
      ..fields['angle'] = angle.toString();

    print("Sending request to server...");
    var response = await request.send().timeout(Duration(seconds: 120));
    print("Received response from server");

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var originalFileName = path.basenameWithoutExtension(imagePath);
      var filePath = '${Directory.systemTemp.path}/${originalFileName}_rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
