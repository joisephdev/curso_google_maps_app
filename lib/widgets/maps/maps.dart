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

  // MARKER PROPS
  BitmapDescriptor? _markerIcon;
  bool _infoMarkerMap = false;
  MarkerSelected? _markerSelected;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  // LOCATION PROPS
  Location? location;
  bool _myLocationEnabled = false;
  final LatLng _currentLatLng = defaultLocation;

  // Build Markers onMap
  void _buildMarkers() {
    final positions = [const LatLng(4.732898371548701, -74.06442115961681)];
    for (var p in positions) {
      _markers[MarkerId(p.toString())] = Marker(
        position: p,
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId(p.toString()),
        zIndex: positions.indexOf(p).toDouble(),
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

  void _locationChanged() {
    if (location != null) {
      location!.onLocationChanged.listen((onData) {
        _updateLocation(onData);
      });
    }
  }

  void _updateLocation(LocationData locationData) {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 14,
        bearing: 90,
        tilt: 45,
        target: LatLng(locationData.latitude!, locationData.longitude!),
      )),
    );

    setState(() => _myLocationEnabled = true);
  }

  void _requestPermission() async {
    location = await Common.requestPermission();
    if (location == null) return _requestPermission();
    LocationData locationData = await location!.getLocation();
    _updateLocation(locationData);
    // _locationChanged();
  }

  void _buildIconMarkerMap() {
    const icon = "assets/images/map_co.png";
    Common.getBytesFromAsset(icon, 84).then((onValue) {
      setState(() => _markerIcon = BitmapDescriptor.fromBytes(onValue));
      _buildMarkers();
    }).catchError((_) {
      _buildMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.setMapStyle(Common.mapStyle());
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
