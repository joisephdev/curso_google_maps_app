import 'dart:convert';

import 'package:app_google_maps_flutter/common/common.dart';
import 'package:app_google_maps_flutter/widgets/maps/marker_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AppMap extends StatefulWidget {
  const AppMap({Key? key}) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

const defaultLocation = LatLng(37.17329763573964, -93.28716123289139);

class _AppMapState extends State<AppMap> {
  // MAP PROPS
  MapType _mapType = MapType.normal;
  GoogleMapController? _mapController;

  // LOCATION PROPS
  Location? location;
  bool _myLocationEnabled = false;
  LatLng _currentLatLng = defaultLocation;

  // MARKER PROPS
  BitmapDescriptor? _markerIcon;
  bool _infoMarkerMap = false;
  MarkerSelected? _markerSelected;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final defaultMarkers = [const LatLng(4.732898371548701, -74.06442115961681)];

  // POLYLINE PROPS
  Set<Polyline> _polyLine = <Polyline>{};

  // For markers method - BuildIcon
  void _buildIconMarkerMap() {
    const icon = "assets/images/map_co.png";
    Common.getBytesFromAsset(icon, 84).then((onValue) {
      setState(() => _markerIcon = BitmapDescriptor.fromBytes(onValue));
    });
  }

  // For markers method - BuildMarkers
  void _buildMarkers() {
    for (var p in defaultMarkers) {
      _markers[MarkerId(p.toString())] = Marker(
        position: p,
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId(p.toString()),
        zIndex: defaultMarkers.indexOf(p).toDouble(),
        icon: _markerIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => setState(() {
          _markerSelected = null;
          _infoMarkerMap = !_infoMarkerMap;
          if (_infoMarkerMap) {
            const iconLocation = "assets/images/codigo_facilito.png";
            _markerSelected = MarkerSelected("My location", p, iconLocation);
          }
        }),
      );
    }
  }

  // For Polyline method - BuildPolyline
  void _buildPolyline() {
    _polyLine.add(
      Polyline(
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.bevel,
        patterns: const <PatternItem>[PatternItem.dot],
        polylineId: const PolylineId("PolylineMap"),
        color: Theme.of(context).primaryColor,
        points: [_currentLatLng, defaultMarkers[0]],
      ),
    );
  }

  /*void _locationChanged() {
    if (location != null) {
      location!.onLocationChanged.listen((onData) {
        _updateLocation(onData);
      });
    }
  }*/

  void _updateLocation(LocationData locationData) {
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 14,
        bearing: 90,
        tilt: 45,
        target: latLng,
      )),
    );

    setState(() {
      _currentLatLng = latLng;
      _myLocationEnabled = true;
      _buildMarkers();
      _buildPolyline();
    });
  }

  void _requestPermission() async {
    location = await Common.requestPermission();
    if (location == null) return _requestPermission();
    LocationData locationData = await location!.getLocation();
    _updateLocation(locationData);
    // _locationChanged();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.setMapStyle(json.encode(Common.mapStyle()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildIconMarkerMap();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: _mapType,
          compassEnabled: false,
          buildingsEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          rotateGesturesEnabled: false,
          onMapCreated: _onMapCreated,
          myLocationEnabled: _myLocationEnabled,
          myLocationButtonEnabled: _myLocationEnabled,
          polylines: _polyLine,
          markers: Set<Marker>.of(_markers.values),
          // 1: world, 5: earth/continent , 10: city, 15: street, 20: buildings
          minMaxZoomPreference: const MinMaxZoomPreference(13, 17),
          initialCameraPosition: CameraPosition(
            zoom: 14,
            bearing: 90,
            tilt: 45,
            target: _currentLatLng,
          ),
        ),
        Common.floatButtons(
          context,
          [
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
        if (_infoMarkerMap)
          InkWell(
            child: MarkerInformation(_markerSelected!),
            onTap: () => setState(() {
              _infoMarkerMap = false;
              _markerSelected = null;
            }),
          )
      ],
    );
  }
}
