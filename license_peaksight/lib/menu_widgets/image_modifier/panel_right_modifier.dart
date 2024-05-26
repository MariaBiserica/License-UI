import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:license_peaksight/constants.dart';

class PanelRightImageModifier extends StatefulWidget {
  final Function(String imagePath)? onImageSelected;

  PanelRightImageModifier({this.onImageSelected});

  @override
  _PanelRightImageModifierState createState() => _PanelRightImageModifierState();
}

class _PanelRightImageModifierState extends State<PanelRightImageModifier> with SingleTickerProviderStateMixin {
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
      // Ensures the selected image path is communicated back right after picking
      if(images.isNotEmpty) {
        widget.onImageSelected?.call(images[currentIndex]);
      }
    }
  }

  void nextImage() {
    if (currentIndex < images.length - 1) {
      setState(() {
        currentIndex++;
        _animationController!.reset();
        _animationController!.forward();
      });
      // Call the callback function with the new image path
      widget.onImageSelected?.call(images[currentIndex]);
      print("Selected image path: ${images[currentIndex]}");
    }
  }

  void previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _animationController!.reset();
        _animationController!.forward();
      });
      // Call the callback function with the new image path
      widget.onImageSelected?.call(images[currentIndex]);
      print("Selected image path: ${images[currentIndex]}");
    }
  }

  void viewImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return ImageDetailView(imagePath: imagePath);
      },
    ));
  }

  Widget buildImage() {
    return GestureDetector(
      onTap: () => viewImage(context, images[currentIndex]),
      child: Hero(
        tag: images[currentIndex],
        child: ScaleTransition(
          scale: _scaleAnimation!,
          child: FadeTransition(
            opacity: _animationController!,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: FileImage(File(images[currentIndex])),
                  fit: BoxFit.cover,
                ),
              ),
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
                    backgroundColor: Constants.panelForeground,
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
                      icon: Icon(Icons.arrow_left, color: Constants.panelForeground),
                      onPressed: images.isEmpty ? null : previousImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right, color: Constants.panelForeground),
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


class ImageDetailView extends StatelessWidget {
  final String imagePath;

  ImageDetailView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: imagePath,
            child: InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }
}
