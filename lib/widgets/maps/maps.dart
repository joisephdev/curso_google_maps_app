import 'package:app_google_maps_flutter/common/common.dart';
import 'package:app_google_maps_flutter/widgets/maps/marker_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  GoogleMapController? _mapController;
  LatLng? _latOnLongProgressMap;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final LatLng _position = const LatLng(4.754308066515901, -74.08905190602582);

  Widget get _floatButtons {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10),
        child: SpeedDial(
          backgroundColor: Theme.of(context).primaryColor,
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

  CameraPosition _cameraPosition() {
    return CameraPosition(target: _position, zoom: 14, bearing: 90, tilt: 45);
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
        /* alpha: 0.5,
        draggable: true,
        onDragEnd: (LatLng position) {},
        infoWindow: InfoWindow(
          title: 'Marker Information',
          snippet: "Lat ${p.latitude} y Long ${p.longitude}",
        ),*/
        position: p,
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId(p.toString()),
        onTap: () {
          _markerSelected = null;
          _showInfo = !_showInfo;
          if (_showInfo) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  zoom: 14,
                  target: LatLng(12.175843310153466, -68.86858253689769),
                ),
              ),
            );
            const iconLocation = "assets/images/codigo_facilito.png";
            _markerSelected = MarkerSelected("My location", p, iconLocation);
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

  CameraPosition _initialCameraPosition() {
    return CameraPosition(
      target: _position,
      zoom: 14,
      bearing: 90,
      tilt: 45,
    );
  }

  _onTapMap(LatLng position) {
    print("_onTapMap ${position.toString()}");
  }

  _onLongProgressMap(LatLng position) {
    _latOnLongProgressMap = position;
    _showPopUpMenu();
  }

  _showPopUpMenu() async {
    String? selected = await showMenu(
      context: context,
      elevation: 8.0,
      position: const RelativeRect.fromLTRB(200, 200, 250, 250),
      items: [
        const PopupMenuItem(child: Text("QueHay"), value: "1"),
        const PopupMenuItem(child: Text("Ir"), value: "2")
      ],
    );

    print("#selected $selected");
    if (selected != null) {
      _getValue(selected);
    }
  }

  _getValue(value) {
    if (value == "1") {
      print("Ubicación: ${_latOnLongProgressMap.toString()}");
    }
  }

  void _buildIcon() {
    const iconLocation = "assets/images/map_co.png";
    Common.getBytesFromAsset(iconLocation, 84).then((onValue) {
      setState(() => _markerIcon = BitmapDescriptor.fromBytes(onValue));
      _loadMarkers();
    });

    /*BitmapDescriptor.fromAssetImage(
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
          markers: Set<Marker>.of(_markers.values),
          initialCameraPosition: _initialCameraPosition(),
          onTap: _onTapMap,
          onLongPress: _onLongProgressMap,
          /*cameraTargetBounds: CameraTargetBounds(LatLngBounds(
            northeast: _position,
            southwest: _position,
          )),*/
          // 1: mundo, 5: Tierra / continente, 10: Ciudad, 15: calles, 20: edificios
          minMaxZoomPreference: const MinMaxZoomPreference(13, 17),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          // Detecta cuando la cámara empieza a moverse
          onCameraMoveStarted: () {
            print("Ha iniciado!");
          },
          // Detecta cuando la cámara deje de moverse
          onCameraIdle: () {
            print("Se ha detenido!");
          },
          // Detecta cuando la cámara se está moviendo
          onCameraMove: (CameraPosition position) {
            print("La posicion $position");
          },
        ),
        _floatButtons,
        if (_showInfo)
          InkWell(
            child: MarkerInformation(_markerSelected!),
            onTap: () => setState(() {
              _markerSelected = null;
              _showInfo = false;
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(_initialCameraPosition()),
              );
            }),
          )
      ],
    );
  }
}
