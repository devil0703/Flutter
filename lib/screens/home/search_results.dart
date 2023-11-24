import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/screens/home/search_page.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/widgets/empty_box.dart';

class AlgoliaApplication {
  static final Algolia algolia = Algolia.init(
    applicationId: 'DFHZ2R1FZ1', //ApplicationID
    apiKey: 'd320aeb47290a79656e15e17c7af69d4', //search-only api key in flutter code
  );
}

class SearchResults extends StatelessWidget {
  final String searchQuery;

  SearchResults({required this.searchQuery});

  final vesselService = Get.find<VesselService>();
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  RxString _searchTerm = ''.obs;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("dev_makaiapp").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SEARCH')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                  autofocus: true,
                  onChanged: (val) {
                    _searchTerm.value = val;
                  },
                  style: new TextStyle(color: Colors.black, fontSize: 20),
                  decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search ...', hintStyle: TextStyle(color: Colors.black), prefixIcon: const Icon(Icons.search, color: Colors.black))),
              SizedBox(height: 10),
              StreamBuilder<List<AlgoliaObjectSnapshot>>(
                stream: Stream.fromFuture(_operation(_searchTerm.value)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Container();
                  else {
                    List<AlgoliaObjectSnapshot>? currSearchStuff = snapshot.data;
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                      default:
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        else
                          return currSearchStuff!.length > 0
                              ? CustomScrollView(
                                  shrinkWrap: true,
                                  slivers: <Widget>[
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          if (_searchTerm.value.length > 0) {
                                            return currSearchStuff[index].data["approved"]
                                                ? SearchItem(
                                                    vesselID: currSearchStuff[index].data["vesselID"],
                                                    vesselName: currSearchStuff[index].data["vesselName"],
                                                    images: currSearchStuff[index].data["images"],
                                                    description: currSearchStuff[index].data["description"],
                                                  )
                                                : Container();
                                          } else {
                                            return Container();
                                          }
                                        },
                                        childCount: currSearchStuff.length ?? 0,
                                      ),
                                    ),
                                  ],
                                )
                              : EmptyBox(text: 'Nothing to show. Try some other keyword');
                    }
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
