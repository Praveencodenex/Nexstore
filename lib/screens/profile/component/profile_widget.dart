import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';


class ProfileImagePicker extends StatelessWidget {
  final File? localImage;
  final String? networkImageUrl;
  final Function(File) onImageSelected;
  final VoidCallback onImageRemoved;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileImagePicker({
    super.key,
    this.localImage,
    this.networkImageUrl,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.radius = 55,
    this.backgroundColor = Colors.grey,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Profile image
          CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor.withOpacity(0.3),
            backgroundImage: localImage != null
                ? FileImage(localImage!)
                : (networkImageUrl != null && networkImageUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(networkImageUrl!)
                : null,
            child: (localImage == null &&
                (networkImageUrl == null || networkImageUrl!.isEmpty))
                ? Icon(
              Icons.person,
              size: radius * 0.8,
              color: iconColor,
            )
                : null,
          ),

          // Camera button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async{
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality:50 );
                if (pickedFile != null) {
                  onImageSelected(File(pickedFile.path));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          // Remove button - only show when a local image is selected
          if (localImage != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onImageRemoved,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}