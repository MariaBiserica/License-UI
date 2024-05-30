import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:license_peaksight/constants.dart';
import 'dart:async';
import 'dart:ui' as ui;

class PanelRightBatchProcessing extends StatefulWidget {
  final Function(List<String> imagePaths)? onImagesSelected;  // Changed to handle a list of File
  final Map<String, Color> themeColors;

  PanelRightBatchProcessing({
    this.onImagesSelected,
    required this.themeColors,
  });

  @override
  _PanelRightBatchProcessingState createState() => _PanelRightBatchProcessingState();
}

class _PanelRightBatchProcessingState extends State<PanelRightBatchProcessing> {
  List<String> images = [];

  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      List<String> paths = result.paths.whereType<String>().toList();
      // List<String> paths = result.paths.map((path) => path!).toList();
      setState(() {
          images.addAll(paths);
          print("Images added to state: ${images.join(', ')}");
      });
      // Ensures the selected image paths are communicated back right after picking
      if (images.isNotEmpty) { 
        widget.onImagesSelected?.call(images);  // Call the callback with the list of images
      }
    }
  }

  void viewImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      pageBuilder: (_, __, ___) => ImageDetailView(imagePath: imagePath),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(Constants.kPadding),
        child: Card(
          color: widget.themeColors['panelBackground'],
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImages,
                child: Text('Upload Images'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: widget.themeColors['textColor'], 
                  backgroundColor: widget.themeColors['panelForeground'],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: images.isEmpty
                  ? Center(child: Text("No images uploaded.", style: TextStyle(color: widget.themeColors['textColor'])))
                  : ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    String imagePath = images[index];
                     return FutureBuilder<ui.Image>(
                       future: _getImageSize(FileImage(File(imagePath))),
                       builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                         final imageSize = snapshot.data != null ? "${snapshot.data!.width} x ${snapshot.data!.height}" : "Loading...";
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () => viewImage(context, imagePath),
                            child: Hero(
                              tag: imagePath,
                              child: Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            imagePath.split('/').last,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.themeColors['textColor'],
                            ),
                          ),
                          subtitle: Text(
                            '${File(imagePath).lengthSync()} bytes - $imageSize',
                            style: TextStyle(
                              fontFamily: 'TellMeAJoke',
                              fontSize: 14,
                              color: widget.themeColors['subtitleColor'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _getImageSize(ImageProvider provider) {
    Completer<ui.Image> completer = Completer<ui.Image>();
    ImageStream stream = provider.resolve(ImageConfiguration());

    ImageStreamListener? listener; // Declare listener as nullable
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        if (listener != null) {
          stream.removeListener(listener); // Use non-null assertion
        }
      }
    );

    stream.addListener(listener);
    return completer.future;
  }
}

class ImageDetailView extends StatelessWidget {
  final String imagePath;

  ImageDetailView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
