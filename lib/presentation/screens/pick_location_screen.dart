import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationResult {
  final double latitude;
  final double longitude;
  final String? resolvedAddress;

  const PickLocationResult({
    required this.latitude,
    required this.longitude,
    this.resolvedAddress,
  });
}

class PickLocationScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const PickLocationScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  GoogleMapController? _mapController;
  late LatLng _selected;
  final _addressController = TextEditingController();
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = (widget.initialLatitude != null && widget.initialLongitude != null)
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _kigaliCenter;
    _addressController.text = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _moveCamera(LatLng target, {double zoom = 16}) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
    );
  }

  Future<void> _searchAddress() async {
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = 'Please enter an address to search.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        setState(() {
          _error = 'No location found for that address.';
        });
        return;
      }

      final first = locations.first;
      final next = LatLng(first.latitude, first.longitude);
      setState(() {
        _selected = next;
      });
      await _moveCamera(next);
    } catch (e) {
      setState(() {
        _error = 'Could not search this address. Try a simpler address.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<String?> _reverseGeocode(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
        if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
      ];
      final deduped = <String>{};
      final cleaned = <String>[];
      for (final part in parts) {
        if (deduped.add(part)) cleaned.add(part);
      }
      return cleaned.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirm() async {
    final resolved = await _reverseGeocode(_selected);
    if (!mounted) return;
    Navigator.of(context).pop(
      PickLocationResult(
        latitude: _selected.latitude,
        longitude: _selected.longitude,
        resolvedAddress: resolved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('selected'),
      position: _selected,
      draggable: true,
      onDragEnd: (p) {
        setState(() {
          _selected = p;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchAddress(),
                    decoration: const InputDecoration(
                      labelText: 'Search address (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchAddress,
                    child: _isSearching
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Find'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selected,
                zoom: 14,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: {marker},
              onTap: (p) {
                setState(() {
                  _selected = p;
                });
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected: ${_selected.latitude.toStringAsFixed(5)}, ${_selected.longitude.toStringAsFixed(5)}',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check),
                  label: const Text('Use this location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

