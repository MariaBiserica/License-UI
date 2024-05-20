import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:license_peaksight/constants.dart';
import 'dart:async';
import 'dart:ui' as ui;

class PanelRightBatchProcessing extends StatefulWidget {
  final Function(List<File>)? onImagesSelected;  // Changed to handle a list of File

  PanelRightBatchProcessing({this.onImagesSelected});

  @override
  _PanelRightBatchProcessingState createState() => _PanelRightBatchProcessingState();
}

class _PanelRightBatchProcessingState extends State<PanelRightBatchProcessing> {
  List<File> images = [];

  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      List<File> newImages = result.paths.map((path) => File(path!)).toList();
      setState(() {
          images.addAll(newImages);
          print("Images added to state: ${images.map((file) => file.path).join(', ')}");
      });
      if (images.isNotEmpty) {  // Check if the callback is not null
        //widget.onImagesSelected?.call(images);  // Call the callback with the list of images
      }
    }
  }

  void viewImage(BuildContext context, File image) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black45, // Slightly darken the background
      pageBuilder: (_, __, ___) => ImageDetailView(imageFile: image),
    ));
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
          child: Column(
            children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImages,
                child: Text('Upload Images'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: Constants.panelForeground,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: images.isEmpty
                  ? Center(child: Text("No images uploaded."))
                  : ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    File image = images[index];
                     return FutureBuilder<ui.Image>(
                       future: _getImageSize(FileImage(image)),
                       builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                         final imageSize = snapshot.data != null ? "${snapshot.data!.width} x ${snapshot.data!.height}" : "Loading...";
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () => viewImage(context, image),
                            child: Hero(
                              tag: image.path,
                              child: Image.file(image, width: 50, height: 50, fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            image.path.split('/').last,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${image.lengthSync()} bytes - $imageSize',
                            style: TextStyle(
                              fontFamily: 'TellMeAJoke',
                              fontSize: 14,
                              color: Color.fromARGB(156, 158, 158, 158),
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
  final File imageFile;

  ImageDetailView({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: imageFile.path,
            child: InteractiveViewer(
              child: Image.file(imageFile),
            ),
          ),
        ),
      ),
    );
  }
}
