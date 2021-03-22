import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(3.157764, 101.711861),
    zoom: 14.4746,
  );
  final Set<Marker> markers = {
    Marker(
      markerId: MarkerId(
        initialCameraPosition.target.toString(),
      ),
      position: initialCameraPosition.target,
    )
  };
  TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              mapType: MapType.hybrid,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(hintText: "Enter place name"),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: onFindPressed,
                child: Text(
                  "Find place",
                  style: Theme.of(context).textTheme.button.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onFindPressed() async {
    final place = _textEditingController.text;
    GooglePlace googlePlace =
        GooglePlace("AIzaSyBzwbL8vLcTs1t1CjM3B4aSJfECdaX-RS8");
    TextSearchResponse result = await googlePlace.search.getTextSearch(place);
    final location = result.results.first?.geometry?.location;
    final viewport = result.results.first?.geometry?.viewport;
    if (location != null) {
      final LatLng latlng = LatLng(location.lat, location.lng);
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(latlng.toString()),
            position: latlng,
          ),
        );
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          latlng,
          getZoom(
            context,
            viewport.southwest.lng,
            viewport.northeast.lng,
          ),
        ),
      );
    }
  }
}

double getZoom(BuildContext context, double southwest, double northeast) {
  const width = 256;
  double angle = northeast - southwest;
  if (angle < 0) {
    angle += 360;
  }
  return math.log(MediaQuery.of(context).size.width * 360 / angle / width) /
      math.ln2;
}
