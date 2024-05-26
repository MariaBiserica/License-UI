import 'dart:io';
import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class PanelCenterImageModifier extends StatelessWidget {
  final String? imagePath;

  PanelCenterImageModifier({required this.imagePath});

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
              height: MediaQuery.of(context).size.height - 2 * Constants.kPadding, // Occupy available height
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Modified Image",
                    style: TextStyle(
                      fontFamily: 'MOXABestine',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  imagePath != null
                      ? Image.file(File(imagePath!))
                      : Text(
                          "No modified image.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
