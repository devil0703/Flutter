import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/widgets/cached_image.dart';

class AlgoliaApplication {
  static final Algolia algolia = Algolia.init(
    applicationId: 'DFHZ2R1FZ1', //ApplicationID
    apiKey: 'd320aeb47290a79656e15e17c7af69d4', //search-only api key in flutter code
  );
}

class SearchBar extends StatefulWidget {
  SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  late String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("dev_makaiapp").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Learning Algolia",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            TextField(
                onChanged: (val) {
                  setState(() {
                    _searchTerm = val;
                  });
                },
                style: new TextStyle(color: Colors.black, fontSize: 20),
                decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search ...', hintStyle: TextStyle(color: Colors.black), prefixIcon: const Icon(Icons.search, color: Colors.black))),
            StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text(
                    "Start Typing",
                    style: TextStyle(color: Colors.black),
                  );
                else {
                  List<AlgoliaObjectSnapshot>? currSearchStuff = snapshot.data;

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      else
                        return CustomScrollView(
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _searchTerm.length > 0
                                      ? SearchItem(
                                          vesselID: currSearchStuff![index].data["vesselID"],
                                          vesselName: currSearchStuff[index].data["vesselName"],
                                          images: currSearchStuff[index].data["images"], description: '',
                                        )
                                      : Container();
                                },
                                childCount: currSearchStuff!.length ?? 0,
                              ),
                            ),
                          ],
                        );
                  }
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class SearchItem extends StatelessWidget {
  final String vesselID;
  final String vesselName;
  final String description;
  final List images;

  SearchItem({Key? key, required this.vesselName,required this.vesselID,required this.images,required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.to(() => ViewVessel(false, vesselID: vesselID)),
      leading: CachedImage(url: images[0], height: 50, circular: true),
      title: Text(
        vesselName ?? "",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
