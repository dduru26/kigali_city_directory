import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing_model.dart';
import '../../state/listings/listings_controller.dart';
import 'pick_location_screen.dart';

class AddEditListingScreen extends ConsumerStatefulWidget {
  final ListingModel? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  ConsumerState<AddEditListingScreen> createState() =>
      _AddEditListingScreenState();
}

class _AddEditListingScreenState extends ConsumerState<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  double? _pickedLatitude;
  double? _pickedLongitude;

  late String _selectedCategory;

  final List<String> _categories = const [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();

    final listing = widget.listing;

    _nameController = TextEditingController(text: listing?.name ?? '');
    _addressController = TextEditingController(text: listing?.address ?? '');
    _contactController = TextEditingController(
      text: listing?.contactNumber ?? '',
    );
    _descriptionController = TextEditingController(
      text: listing?.description ?? '',
    );
    _pickedLatitude = listing?.latitude;
    _pickedLongitude = listing?.longitude;

    _selectedCategory = listing?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.of(context).push<PickLocationResult>(
      MaterialPageRoute(
        builder: (_) => PickLocationScreen(
          initialLatitude: _pickedLatitude,
          initialLongitude: _pickedLongitude,
          initialAddress: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _pickedLatitude = result.latitude;
      _pickedLongitude = result.longitude;
    });

    if ((result.resolvedAddress ?? '').trim().isNotEmpty &&
        _addressController.text.trim().isEmpty) {
      _addressController.text = result.resolvedAddress!.trim();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedLatitude == null || _pickedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on the map.')),
      );
      return;
    }

    final controller = ref.read(listingsControllerProvider.notifier);

    bool success;

    if (isEditing) {
      success = await controller.updateListing(
        existingListing: widget.listing!,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _pickedLatitude!,
        longitude: _pickedLongitude!,
      );
    } else {
      success = await controller.createListing(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _pickedLatitude!,
        longitude: _pickedLongitude!,
      );
    }

    if (!mounted) return;

    final state = ref.read(listingsControllerProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ?? state.successMessage ?? 'Operation completed.',
        ),
      ),
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(listingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Listing' : 'Add Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place or Service Name *',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a place or service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Location *'),
                  subtitle: Text(
                    _pickedLatitude == null || _pickedLongitude == null
                        ? 'No location selected'
                        : '${_pickedLatitude!.toStringAsFixed(5)}, ${_pickedLongitude!.toStringAsFixed(5)}',
                  ),
                  trailing: const Icon(Icons.map_outlined),
                  onTap: _pickOnMap,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: listingsState.isLoading ? null : _submit,
                  child: listingsState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Update Listing' : 'Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
