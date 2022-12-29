import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'logger.dart';

class MapLocationPicker extends StatefulWidget {
  /// Padding around the map
  final EdgeInsets padding;

  /// GPS accuracy for the map
  final LocationAccuracy desiredAccuracy;

  /// Map minimum zoom level & maximum zoom level
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Top card margin
  final EdgeInsetsGeometry topCardMargin;

  /// Top card color
  final Color? topCardColor;

  /// Top card shape
  final ShapeBorder topCardShape;

  /// Top card text field border radius
  final BorderRadius? borderRadius;

  /// Bottom card shape
  final ShapeBorder bottomCardShape;

  /// Bottom card margin
  final EdgeInsetsGeometry bottomCardMargin;

  /// Bottom card color
  final Color? bottomCardColor;

  /// On Next Page callback
  final Function(LatLng?, Placemark?) onNext;

  /// Show back button (default: true)
  final bool showBackButton;

  /// Popup route on next press (default: false)
  final bool canPopOnNextButtonTaped;

  /// Back button replacement when [showBackButton] is false and [backButton] is not null
  final Widget? backButton;

  /// Show more suggestions
  final bool showMoreOptions;

  /// Dialog title
  final String dialogTitle;

  /// Offset for pagination of results
  /// offset: int,
  final num? offset;

  /// Origin location for calculating distance from results
  /// origin: Location(lat: -33.852, lng: 151.211),
  final Location? origin;

  /// currentLatLng init location for camera position
  /// currentLatLng: Location(lat: -33.852, lng: 151.211),
  final LatLng? currentLatLng;

  /// Location bounds for restricting results to a radius around a location
  /// location: Location(lat: -33.867, lng: 151.195)
  final Location? location;

  /// Radius for restricting results to a radius around a location
  /// radius: Radius in meters
  final num? radius;

  /// Bounds for restricting results to a set of bounds
  final bool strictbounds;

  /// Search text field controller
  final TextEditingController? searchController;

  final Color? primaryColor;

  const MapLocationPicker({
    Key? key,
    this.desiredAccuracy = LocationAccuracy.high,
    this.minMaxZoomPreference = const MinMaxZoomPreference(10, 20),
    this.padding = const EdgeInsets.all(0),
    this.topCardMargin = const EdgeInsets.all(8),
    this.topCardColor,
    this.topCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.bottomCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.bottomCardMargin = const EdgeInsets.fromLTRB(8, 8, 8, 16),
    this.bottomCardColor,
    required this.onNext,
    this.currentLatLng = const LatLng(28.8993468, 76.6250249),
    this.showBackButton = true,
    this.canPopOnNextButtonTaped = false,
    this.backButton,
    this.showMoreOptions = true,
    this.dialogTitle = 'You can also use the following options',
    this.offset,
    this.origin,
    this.location,
    this.radius,
    this.strictbounds = false,
    this.searchController,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  /// Map controller for movement & zoom
  final Completer<GoogleMapController> _controller = Completer();

  /// initial latitude & longitude
  LatLng _initialPosition = const LatLng(27.7172, 85.3240);

  /// initial address text
  String _address = "Tap on map to get address";

  /// initial zoom level
  double _zoom = 18.0;

  // Placemark
  Placemark? _selectedPlace;

  // Selected LatLng
  LatLng? _selectedLatLng;

  //List of place mark
  List<Placemark> _allPlacemarks = [];

  /// Camera position moved to location
  CameraPosition cameraPosition() {
    return CameraPosition(
      target: _initialPosition,
      zoom: _zoom,
    );
  }

  /// Search text field controller
  late TextEditingController _searchController = TextEditingController();

  /// Decode address from latitude & longitude
  void _decodeAddress(LatLng location) async {
    try {
      final geocoding =
          await placemarkFromCoordinates(location.latitude, location.longitude);

      /// When get any error from the API, show the error in the console.
      if (geocoding.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Address not found, something went wrong!"),
            ),
          );
        }
        return;
      }
      _address = geocoding.first.formatedStreet;
      _selectedPlace = geocoding.first;
      _selectedLatLng = location;
      setState(() {
        _allPlacemarks = geocoding.fold(
          [],
          (pv, e) => [
            ...pv,
            if (pv.indexWhere(
                    (val) => val.formatedStreet == e.formatedStreet) ==
                -1)
              e
          ],
        );
      });
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    _searchController = widget.searchController ?? _searchController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            minMaxZoomPreference: widget.minMaxZoomPreference,
            onCameraMove: (CameraPosition position) {
              _zoom = position.zoom;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: _zoom,
            ),
            onTap: (LatLng position) async {
              _initialPosition = position;
              final controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition()));
              _decodeAddress(
                LatLng(
                  position.latitude,
                  position.longitude,
                ),
              );
              setState(() {});
            },
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('one'),
                position: _initialPosition,
              ),
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            padding: widget.padding,
            mapType: MapType.normal,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: widget.primaryColor ?? _theme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor:
                      widget.primaryColor ?? Theme.of(context).primaryColor,
                  onPressed: () async {
                    final locationPermission =
                        await Geolocator.requestPermission();
                    if (locationPermission == LocationPermission.always ||
                        locationPermission == LocationPermission.whileInUse) {
                      Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: widget.desiredAccuracy,
                      );
                      LatLng latLng =
                          LatLng(position.latitude, position.longitude);
                      _initialPosition = latLng;
                      final controller = await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(cameraPosition()));
                      _decodeAddress(
                        LatLng(position.latitude, position.longitude),
                      );
                      setState(() {});
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
              Card(
                margin: widget.bottomCardMargin,
                shape: widget.bottomCardShape,
                color: widget.bottomCardColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(_address),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: widget.primaryColor ?? _theme.primaryColor,
                        ),
                        onPressed: () async {
                          widget.onNext.call(_selectedLatLng, _selectedPlace);
                          if (widget.canPopOnNextButtonTaped) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    if (widget.showMoreOptions && _allPlacemarks.length > 1)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              titlePadding: EdgeInsets.zero,
                              title: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.dialogTitle,
                                            style: _theme.textTheme.bodyLarge!
                                                .copyWith(fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 50)
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.close_outlined),
                                    ),
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              scrollable: true,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _allPlacemarks.map((e) {
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xAADFDFDF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          e.formatedStreet,
                                          maxLines: 2,
                                        ),
                                      ),
                                      onTap: () {
                                        _address = e.formatedStreet;
                                        _selectedPlace = e;
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        child: Chip(
                          backgroundColor:
                              widget.primaryColor?.withOpacity(0.8) ??
                                  _theme.primaryColor.withOpacity(0.8),
                          label: Text(
                            "Tap to show ${(_allPlacemarks.length - 1)} more result options",
                            style: _theme.textTheme.caption!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
