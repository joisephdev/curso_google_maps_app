import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInformation extends StatelessWidget {
  final MarkerSelected markerInfo;

  const MarkerInformation(this.markerInfo, {Key? key}) : super(key: key);

  TextStyle get _infoStyle {
    return const TextStyle(
      fontSize: 12.0,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            width: 50,
            height: 50,
            child: ClipOval(
              child: Image.asset(markerInfo.image, fit: BoxFit.cover),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  markerInfo.title,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Latitude: ${markerInfo.latLng.latitude}',
                  style: _infoStyle,
                ),
                Text(
                  'Longitude: ${markerInfo.latLng.longitude}',
                  style: _infoStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarkerSelected {
  final String title;
  final LatLng latLng;
  final String image;

  MarkerSelected(this.title, this.latLng, this.image);
}
