// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/models/forum_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class WritePost extends StatefulWidget {
  final Vessel vessel;
  final Forum forum;

  WritePost({required this.vessel, required this.forum});

  @override
  State<WritePost> createState() => _WritePostState();
}

class _WritePostState extends State<WritePost> {
  final storageService = Get.find<StorageService>();
  final vesselService = Get.find<VesselService>();
  final dialogService = Get.find<DialogService>();

  RxList images = [].obs;
  RxList imageURLs = [].obs;

  final TextEditingController postTEC = TextEditingController();

  @override
  void initState() {
    postTEC.text = widget.forum.comment!;
    imageURLs.value = widget.forum.images!;
      super.initState();
  }

  @override
  void dispose() {
    imageURLs = null as RxList;
    images = null as RxList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forum == null ? 'WRITE A POST' : 'EDIT POST'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => imageURLs.value.isEmpty
                  ? Container()
                  : GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 25),
                      itemCount: imageURLs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 10, crossAxisSpacing: 10),
                      itemBuilder: (context, i) {
                        return InkWell(
                          onTap: () => imageURLs.remove(imageURLs[i]),
                          child: Stack(
                            children: [
                              CachedImage(height: double.infinity, roundedCorners: true, url: imageURLs[i]),
                              Icon(Icons.circle, color: Colors.white, size: 25),
                              Icon(Icons.remove_circle, color: redColor, size: 25),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Obx(
              () => GridView.builder(
                padding: const EdgeInsets.only(bottom: 25),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 10, crossAxisSpacing: 10),
                itemCount: images.length + 1,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  if (i == 0)
                    return addImageButton();
                  else
                    return InkWell(
                      onTap: () => images.remove(images[i - 1]),
                      child: Stack(
                        children: [
                          CachedImage(height: double.infinity, roundedCorners: true, imageFile: images[i - 1]),
                          Icon(Icons.circle, color: Colors.white, size: 25),
                          Icon(Icons.remove_circle, color: redColor, size: 25),
                        ],
                      ),
                    );
                },
              ),
            ),
            CustomTextField(controller: postTEC, label: '', hint: 'Enter your comments', validate: true, maxLines: 5),
            Expanded(child: Container()),
            CustomButton(
              text: widget.forum == null ? 'Post' : 'Save',
              function: () async {
                if (postTEC.text.isEmpty) {
                  showRedAlert('Please enter your comment');
                  return;
                }
                dialogService.showLoading();
                for (int i = 0; i < images.length; i++) {
                  imageURLs.add(await storageService.uploadPhoto(images[i], 'forum'));
                }
                if (widget.forum == null)
                  await vesselService.addPost(Forum(
                    images: imageURLs,
                    vesselID: widget.vessel.vesselID,
                    comment: postTEC.text,
                  ));
                else
                  await vesselService.updatePost(Forum(
                    postID: widget.forum.postID,
                    images: imageURLs,
                    vesselID: widget.vessel.vesselID,
                    comment: postTEC.text,
                  ));
              },
            ),
          ],
        ),
      ),
    );
  }

  addImageButton() {
    return InkWell(
      onTap: () async {
        File file = await storageService.pickImage();
        images.add(file);
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
        child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 25),
      ),
    );
  }
}
