import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> saveImageLocally(BuildContext context) async {
    if (imagePath == null) return;

    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'modified_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    if (result != null) {
      final savePath = result;

      try {
        final bytes = await File(imagePath!).readAsBytes();
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

  Future<void> exportImage(BuildContext context) async {
    if (imagePath == null) return;

    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Image', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Enter email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final String email = emailController.text;
              if (email.isNotEmpty) {
                final Email emailToSend = Email(
                  body: 'Attached is the modified image.',
                  subject: 'Modified Image',
                  recipients: [email],
                  attachmentPaths: [imagePath!],
                );

                try {
                  await FlutterEmailSender.send(emailToSend);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image sent to $email')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send image: $e')),
                  );
                }
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
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
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => saveImageLocally(context),
                          child: Text('Save', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.panelForeground,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => exportImage(context),
                          child: Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.panelForeground,
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
