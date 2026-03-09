import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing_model.dart';
import '../../state/listings/listings_controller.dart';

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
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

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
    _latitudeController = TextEditingController(
      text: listing != null ? listing.latitude.toString() : '',
    );
    _longitudeController = TextEditingController(
      text: listing != null ? listing.longitude.toString() : '',
    );

    _selectedCategory = listing?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(listingsControllerProvider.notifier);

    final latitude = double.parse(_latitudeController.text.trim());
    final longitude = double.parse(_longitudeController.text.trim());

    bool success;

    if (isEditing) {
      success = await controller.updateListing(
        existingListing: widget.listing!,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: latitude,
        longitude: longitude,
      );
    } else {
      success = await controller.createListing(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: latitude,
        longitude: longitude,
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
                  labelText: 'Place or Service Name',
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
                decoration: const InputDecoration(labelText: 'Category'),
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
                decoration: const InputDecoration(labelText: 'Address'),
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
                decoration: const InputDecoration(labelText: 'Contact Number'),
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
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Latitude'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter latitude';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid latitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter longitude';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: listingsState.isLoading ? null : _submit,
                  child: listingsState.isLoading
                      ? const CircularProgressIndicator()
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
