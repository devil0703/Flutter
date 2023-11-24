import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final double? height;
  final String? url;
  final bool? roundedCorners;
  final bool? circular;
  final File? imageFile;

  CachedImage({this.height, this.url, this.roundedCorners, this.circular, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular ?? false
          ? 100
          : roundedCorners ?? true
              ? 10
              : 0),
      child: imageFile != null
          ? Image.file(
              imageFile!,
              fit: BoxFit.cover,
              height: height,
              width: height,
            )
          : CachedNetworkImage(
              imageUrl: url ?? '',
              fit: BoxFit.cover,
              height: height,
              width: height,
              placeholder: (context, url) => showImage(url),
              errorWidget: (context, url, error) => errorImage(url),
            ),
    );
  }

  showImage(String url) {
    return Image.asset('assets/images/loading.gif', height: height);
  }

  errorImage(String url) {
    if (url == 'profile')
      return Image.asset('assets/images/profile.png', height: height, fit: BoxFit.cover);
    else
      return Image.asset('assets/images/dummy.png', height: height);
  }
}
