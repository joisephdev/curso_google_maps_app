import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_con_flutter/widgets/maps/marker_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppMap extends StatefulWidget {
  const AppMap({Key? key}) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  bool _showInfo = false;
  MarkerSelected? _markerSelected;
  MapType _mapType = MapType.normal;
  BitmapDescriptor? _markerIcon;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final LatLng _position = const LatLng(4.754308066515901, -74.08905190602582);

  Widget get _floatButtons {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10),
        child: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          elevation: 8.0,
          children: [
            SpeedDialChild(
              label: "NORMAL",
              child: const Icon(Icons.room),
              onTap: () => setState(() => _mapType = MapType.normal),
            ),
            SpeedDialChild(
              label: "SATELLITE",
              child: const Icon(Icons.satellite),
              onTap: () => setState(() => _mapType = MapType.satellite),
            ),
            SpeedDialChild(
              label: "HYBRID",
              child: const Icon(Icons.compare),
              onTap: () => setState(() => _mapType = MapType.hybrid),
            ),
            SpeedDialChild(
              label: "TERRAIN",
              child: const Icon(Icons.terrain),
              onTap: () => setState(() => _mapType = MapType.terrain),
            ),
          ],
        ),
      ),
    );
  }

  CameraPosition get _cameraPosition {
    return CameraPosition(target: _position, zoom: 13);
  }

  _onDragEnd(LatLng position) {
    print("_onDragEnd $position");
  }

  void _loadMarkers() {
    final positions = [
      // _position,
      const LatLng(4.732898371548701, -74.06442115961681)
    ];

    for (var p in positions) {
      _markers[MarkerId(p.toString())] = Marker(
        // alpha: 0.5,
        position: p,
        draggable: true,
        onDragEnd: _onDragEnd,
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId(p.toString()),
        /*  infoWindow: InfoWindow(
          title: 'Marker Information',
          snippet: "Lat ${p.latitude} y Long ${p.longitude}",
        ),*/
        onTap: () {
          print("OnTapped");
          _showInfo = !_showInfo;
          print("_showInfo! $_showInfo");
          if (_showInfo) {
            const iconLocation = "assets/images/codigo_facilito.png";
            _markerSelected = MarkerSelected("My location", p, iconLocation);
          } else {
            _markerSelected = null;
          }
          setState(() {});
        },
        zIndex: positions.indexOf(p).toDouble(),
        icon: _markerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
      );
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _buildIcon() {
    const iconLocation = "assets/images/map_co.png";
    getBytesFromAsset(iconLocation, 76).then((onValue) {
      setState(() => _markerIcon = BitmapDescriptor.fromBytes(onValue));
      _loadMarkers();
    });

/*    BitmapDescriptor.fromAssetImage(
      createLocalImageConfiguration(context, size: const Size.fromHeight(12)),
      "assets/images/map_co.png",
    ).then((i) => setState(() => _markerIcon = i));*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: _mapType,
          zoomControlsEnabled: false,
          initialCameraPosition: _cameraPosition,
          markers: Set<Marker>.of(_markers.values),
        ),
        _floatButtons,
        if (_showInfo) MarkerInformation(_markerSelected!)
      ],
    );
  }
}
