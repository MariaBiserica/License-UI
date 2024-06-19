import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:license_peaksight/constants.dart';
import 'dart:async';
import 'dart:ui' as ui;

class PanelRightBatchProcessing extends StatefulWidget {
  final Function(List<String> imagePaths)? onImagesSelected;
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
      setState(() {
        images.addAll(paths);
        print("Images added to state: ${images.join(', ')}");
      });

      if (images.isNotEmpty) {
        widget.onImagesSelected?.call(images);
      }
    }
  }

  Future<void> pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      List<String> paths = [];
      await _traverseDirectory(selectedDirectory, paths, true);

      setState(() {
        images.addAll(paths);
        print("Images added to state: ${images.join(', ')}");
      });

      if (images.isNotEmpty) {
        widget.onImagesSelected?.call(images);
      }
    }
  }

  Future<void> _traverseDirectory(String dirPath, List<String> paths, bool includeSubfolders) async {
    Directory dir = Directory(dirPath);

    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is File && _isImageFile(entity.path)) {
        paths.add(entity.path);
      } else if (entity is Directory) {
        bool shouldIncludeSubfolder = await _promptIncludeSubfolder(entity.path);
        if (shouldIncludeSubfolder) {
          await _traverseDirectory(entity.path, paths, true);
        }
      }
    }
  }

  bool _isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'].contains(extension);
  }

  Future<bool> _promptIncludeSubfolder(String subfolderPath) async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Include Subfolder?'),
          content: Text('Do you want to include images from the subfolder "$subfolderPath"?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    )) ?? false;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: pickImages,
                    child: Text('Upload Images'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.themeColors['textColor'], 
                      backgroundColor: widget.themeColors['panelForeground'],
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: pickFolder,
                    child: Text('Upload Folder'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.themeColors['textColor'], 
                      backgroundColor: widget.themeColors['panelForeground'],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: images.isEmpty
                  ? Center(child: Text("No images uploaded.", style: TextStyle(color: widget.themeColors['textColor'], fontSize: 18)))
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          title: Text(
                            imagePath.split('/').last,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.themeColors['textColor'],
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          subtitle: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.themeColors['subtitleBackgroundColor'],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 0.2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              '${File(imagePath).lengthSync()} bytes - $imageSize',
                              style: TextStyle(
                                fontFamily: 'TellMeAJoke',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: widget.themeColors['scoresColor'],
                              ),
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

    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener!);
      },
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
