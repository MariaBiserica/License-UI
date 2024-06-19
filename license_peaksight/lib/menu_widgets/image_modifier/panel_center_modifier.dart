import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:license_peaksight/constants.dart';

class PanelCenterImageModifier extends StatelessWidget {
  final Future<String?>? imagePathFuture;
  final Map<String, Color> themeColors;

  PanelCenterImageModifier({
    required this.imagePathFuture,
    required this.themeColors,
  });

  void viewImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return ImageDetailView(imagePath: imagePath);
      },
    ));
  }

  Future<void> saveImageLocally(BuildContext context, String imagePath) async {
    String originalImageName = imagePath.split('/').last;

    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      // Extracted the original image name and the "_modified" suffix along with the time stamp will be added automatically
      fileName: '$originalImageName',
    );

    if (result != null) {
      final savePath = result;

      try {
        final bytes = await File(imagePath).readAsBytes();
        await File(savePath).writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $savePath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save path not selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Card(
            color: themeColors['panelBackground'],
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity, // Occupy all available width
              height: MediaQuery.of(context).size.height - 13 * Constants.kPadding,
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0), // Adjust padding to avoid overlap with title
                    child: Center(
                      child: FutureBuilder<String?>(
                        future: imagePathFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: SpinKitFadingFour(
                                color: themeColors['textColor'],
                                size: 50.0,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              "Error loading image.",
                              style: TextStyle(color: themeColors['textColor'], fontSize: 16),
                            );
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return Text(
                              "No modified image.",
                              style: TextStyle(color: themeColors['textColor'], fontSize: 18),
                            );
                          } else {
                            final imagePath = snapshot.data!;
                            return GestureDetector(
                              onTap: () => viewImage(context, imagePath),
                              child: Hero(
                                tag: imagePath,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(File(imagePath)),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Card(
                      color: themeColors['panelBackground']!.withOpacity(0.8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Constants.kPadding),
                        child: Text(
                          "Modified Image",
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontSize: 35,
                            color: themeColors['textColor'],
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final imagePath = await imagePathFuture;
                            if (imagePath != null) {
                              saveImageLocally(context, imagePath);
                            }
                          },
                          child: Text('Save', style: TextStyle(color: themeColors['textColor'])),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColors['panelForeground'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
