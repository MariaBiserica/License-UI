import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:license_peaksight/constants.dart';

class PanelRightPage extends StatefulWidget {
  @override
  _PanelRightPageState createState() => _PanelRightPageState();
}

class _PanelRightPageState extends State<PanelRightPage> with SingleTickerProviderStateMixin {
  List<String> images = [];
  int currentIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut);
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      List<String> paths = result.paths.whereType<String>().toList();
      setState(() {
        images.addAll(paths);
        _animationController!.reset();
        _animationController!.forward();
      });
    }
  }

  void nextImage() {
    if (currentIndex < images.length - 1) {
      setState(() {
        currentIndex++;
        _animationController!.reset();
        _animationController!.forward();
      });
    }
  }

  void previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _animationController!.reset();
        _animationController!.forward();
      });
    }
  }

  Widget buildImage() {
  // Use a Container with BoxDecoration to ensure the rounded corners are maintained.
  return ScaleTransition(
    scale: _scaleAnimation!,
    child: FadeTransition(
      opacity: _animationController!,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Use a DecorationImage to display the image within the Container.
          image: DecorationImage(
            image: FileImage(File(images[currentIndex])),
            fit: BoxFit.fill,
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(Constants.kPadding),
        child: Card(
          color: Constants.purpleLight,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(Constants.kPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: pickImages,
                  child: Text('Upload Images'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Constants.blue,
                  ),
                ),
                SizedBox(height: 20), // Adjust the space as needed
                if (images.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: buildImage(),
                    ),
                  ),
                SizedBox(height: 20), // Adjust the space as needed
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left, color: Constants.blue),
                      onPressed: images.isEmpty ? null : previousImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right, color: Constants.blue),
                      onPressed: images.isEmpty ? null : nextImage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
