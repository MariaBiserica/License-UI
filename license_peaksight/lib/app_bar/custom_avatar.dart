import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackAsset;

  const CustomAvatar({
    Key? key,
    required this.imageUrl,
    required this.fallbackAsset
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 60,  // Set the size of the image (adjust as needed)
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If the network image fails to load, use an AssetImage
          return Image.asset(
            fallbackAsset,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
