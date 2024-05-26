import 'dart:io';
import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class PanelCenterImageModifier extends StatelessWidget {
  final String? imagePath;

  PanelCenterImageModifier({required this.imagePath});

  void viewImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return ImageDetailView(imagePath: imagePath);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Card(
            color: Constants.purpleLight,
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
                  Center(
                    child: imagePath != null
                        ? GestureDetector(
                            onTap: () => viewImage(context, imagePath!),
                            child: Hero(
                              tag: imagePath!,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(File(imagePath!)),
                              ),
                            ),
                          )
                        : Text(
                            "No modified image.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Card(
                      color: Color.fromARGB(255, 71, 2, 77).withOpacity(0.8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Constants.kPadding),
                        child: Text(
                          "Modified Image",
                          style: TextStyle(
                            fontFamily: 'MOXABestine',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
