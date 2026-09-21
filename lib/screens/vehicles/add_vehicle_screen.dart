import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';

class VehicleCatalogItem {
  final String id;
  final String brand;
  final String model;

  const VehicleCatalogItem({
    required this.id,
    required this.brand,
    required this.model,
  });

  String get displayName => '$brand $model';
}

class VehicleCatalogService {
  Future<List<VehicleCatalogItem>> getVehicleModels(
    String vehicleType,
  ) async {
    if (vehicleType == '2 Wheeler') {
      return const [
        VehicleCatalogItem(
          id: '2w-001',
          brand: 'Bajaj',
          model: 'Pulsar 150',
        ),
        VehicleCatalogItem(
          id: '2w-002',
          brand: 'Bajaj',
          model: 'Pulsar N160',
        ),
        VehicleCatalogItem(
          id: '2w-003',
          brand: 'Bajaj',
          model: 'Pulsar NS200',
        ),
        VehicleCatalogItem(
          id: '2w-004',
          brand: 'Bajaj',
          model: 'Dominar 400',
        ),
        VehicleCatalogItem(
          id: '2w-005',
          brand: 'Hero',
          model: 'Splendor Plus',
        ),
        VehicleCatalogItem(
          id: '2w-006',
          brand: 'Honda',
          model: 'Shine',
        ),
        VehicleCatalogItem(
          id: '2w-007',
          brand: 'TVS',
          model: 'Apache RTR 160',
        ),
        VehicleCatalogItem(
          id: '2w-008',
          brand: 'Royal Enfield',
          model: 'Classic 350',
        ),
        VehicleCatalogItem(
          id: '2w-009',
          brand: 'Yamaha',
          model: 'MT-15',
        ),
      ];
    }

    return const [
      VehicleCatalogItem(
        id: '4w-001',
        brand: 'Tata',
        model: 'Nexon',
      ),
      VehicleCatalogItem(
        id: '4w-002',
        brand: 'Tata',
        model: 'Punch',
      ),
      VehicleCatalogItem(
        id: '4w-003',
        brand: 'Maruti Suzuki',
        model: 'Swift',
      ),
      VehicleCatalogItem(
        id: '4w-004',
        brand: 'Maruti Suzuki',
        model: 'Baleno',
      ),
      VehicleCatalogItem(
        id: '4w-005',
        brand: 'Hyundai',
        model: 'i20',
      ),
      VehicleCatalogItem(
        id: '4w-006',
        brand: 'Hyundai',
        model: 'Creta',
      ),
      VehicleCatalogItem(
        id: '4w-007',
        brand: 'Honda',
        model: 'City',
      ),
      VehicleCatalogItem(
        id: '4w-008',
        brand: 'Mahindra',
        model: 'XUV 3XO',
      ),
      VehicleCatalogItem(
        id: '4w-009',
        brand: 'Toyota',
        model: 'Urban Cruiser Hyryder',
      ),
    ];
  }
}

class AddVehicleScreen extends StatefulWidget {
  final String vehicleType;
  final Vehicle? existingVehicle;

  const AddVehicleScreen({
    super.key,
    required this.vehicleType,
    this.existingVehicle,
  });

  @override
  State<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends State<AddVehicleScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _registrationController =
      TextEditingController();

  final TextEditingController _yearController =
      TextEditingController();

  final TextEditingController _odometerController =
      TextEditingController();

  final VehicleCatalogService _catalogService =
      VehicleCatalogService();

  final VehicleService _vehicleService =
      VehicleService();

  List<VehicleCatalogItem> _vehicleModels = [];

  VehicleCatalogItem? _selectedVehicleModel;

  bool _isLoadingModels = true;
  bool _isSaving = false;

  bool get isEditing =>
      widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();

    _registrationController.text =
        widget.existingVehicle?.registrationNumber ?? '';

    _yearController.text =
        widget.existingVehicle?.year.toString() ?? '';

    if (widget.existingVehicle != null) {
      _odometerController.text =
          _formatNumber(
        widget.existingVehicle!.currentOdometer,
      );
    }

    _loadVehicleModels();
  }

  Future<void> _loadVehicleModels() async {
    try {
      final List<VehicleCatalogItem> models =
          await _catalogService.getVehicleModels(
        widget.vehicleType,
      );

      VehicleCatalogItem? selected;

      if (widget.existingVehicle != null) {
        for (final VehicleCatalogItem item in models) {
          if (item.brand ==
                  widget.existingVehicle!.brand &&
              item.model ==
                  widget.existingVehicle!.model) {
            selected = item;
            break;
          }
        }

        if (selected == null &&
            widget.existingVehicle!.brand
                .trim()
                .isNotEmpty &&
            widget.existingVehicle!.model
                .trim()
                .isNotEmpty) {
          selected = VehicleCatalogItem(
            id:
                'saved-${widget.existingVehicle!.id}',
            brand: widget.existingVehicle!.brand,
            model: widget.existingVehicle!.model,
          );

          models.add(selected);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicleModels = models;
        _selectedVehicleModel = selected;
        _isLoadingModels = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingModels = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load vehicle models.',
          ),
        ),
      );
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final VehicleCatalogItem? selectedModel =
        _selectedVehicleModel;

    if (selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a brand and model.',
          ),
        ),
      );
      return;
    }

    final double? odometer =
        double.tryParse(
      _odometerController.text.trim(),
    );

    if (odometer == null || odometer < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid odometer reading.',
          ),
        ),
      );
      return;
    }

    final int? year =
        int.tryParse(
      _yearController.text.trim(),
    );

    if (year == null ||
        year < 1980 ||
        year > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid manufacturing year.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final Vehicle vehicle = Vehicle(
      id: widget.existingVehicle?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      vehicleType: widget.vehicleType,
      registrationNumber:
          _registrationController.text
              .trim()
              .toUpperCase(),
      brand: selectedModel.brand,
      model: selectedModel.model,
      year: year,
      currentOdometer: odometer,
    );

    try {
      if (isEditing) {
        await _vehicleService.updateVehicle(
          vehicle,
        );
      } else {
        await _vehicleService.saveVehicle(
          vehicle,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        vehicle,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save vehicle.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Vehicle'
              : 'Add Vehicle',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                _buildVehicleTypeField(),

                const SizedBox(height: 16),

                _buildVehicleModelField(),

                const SizedBox(height: 16),

                _buildRegistrationField(),

                const SizedBox(height: 16),

                _buildYearField(),

                const SizedBox(height: 18),

                _buildOdometerField(),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSaving
                            ? null
                            : _saveVehicle,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing
                                ? 'Save Changes'
                                : 'Add Vehicle',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          isEditing
              ? 'Update your vehicle'
              : 'Add your vehicle',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEditing
              ? 'Update the details of your vehicle.'
              : 'Enter the basic information to start tracking your vehicle.',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeField() {
    return TextFormField(
      initialValue: widget.vehicleType,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Vehicle Type',
        prefixIcon: Icon(
          Icons.directions_car_outlined,
        ),
      ),
    );
  }

  Widget _buildVehicleModelField() {
    if (_isLoadingModels) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Brand & Model',
          prefixIcon: Icon(
            Icons.directions_car_outlined,
          ),
        ),
        child: SizedBox(
          height: 24,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<
        VehicleCatalogItem>(
      initialValue: _selectedVehicleModel,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Brand & Model *',
        prefixIcon: Icon(
          Icons.directions_car_outlined,
        ),
      ),
      items: _vehicleModels.map(
        (VehicleCatalogItem item) {
          return DropdownMenuItem<
              VehicleCatalogItem>(
            value: item,
            child: Text(
              item.displayName,
              overflow:
                  TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (
        VehicleCatalogItem? value,
      ) {
        setState(() {
          _selectedVehicleModel = value;
        });
      },
      validator: (
        VehicleCatalogItem? value,
      ) {
        if (value == null) {
          return 'Please select a vehicle model';
        }

        return null;
      },
    );
  }

  Widget _buildRegistrationField() {
    return TextFormField(
      controller: _registrationController,
      textCapitalization:
          TextCapitalization.characters,
      decoration: const InputDecoration(
        labelText:
            'Registration / Plate Number *',
        hintText: 'e.g. MH12AB1234',
        prefixIcon: Icon(
          Icons.confirmation_number_outlined,
        ),
      ),
      validator: (String? value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please enter the registration number';
        }

        return null;
      },
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      controller: _yearController,
      keyboardType:
          TextInputType.number,
      decoration: const InputDecoration(
        labelText:
            'Manufacturing Year *',
        hintText: 'e.g. 2024',
        prefixIcon: Icon(
          Icons.calendar_today_outlined,
        ),
      ),
      validator: (String? value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please enter the manufacturing year';
        }

        final int? year =
            int.tryParse(value.trim());

        if (year == null) {
          return 'Enter a valid year';
        }

        if (year < 1980 ||
            year > DateTime.now().year) {
          return 'Enter a valid manufacturing year';
        }

        return null;
      },
    );
  }

  Widget _buildOdometerField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryColor
              .withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: _odometerController,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText:
              'Current Odometer Reading *',
          hintText: 'e.g. 12500',
          prefixIcon: const Icon(
            Icons.speed_outlined,
            color: AppTheme.primaryColor,
          ),
          suffixText: 'km',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              color:
                  AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          helperText:
              'Required for service and mileage tracking',
          helperStyle:
              const TextStyle(
            color:
                AppTheme.secondaryText,
          ),
        ),
        validator: (String? value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Please enter the odometer reading';
          }

          final double? odometer =
              double.tryParse(
            value.trim(),
          );

          if (odometer == null ||
              odometer < 0) {
            return 'Enter a valid odometer reading';
          }

          return null;
        },
      ),
    );
  }
}