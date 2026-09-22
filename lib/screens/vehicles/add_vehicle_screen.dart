import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../services/nhtsa_vehicle_service.dart';
import '../../services/vehicle_service.dart';

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

  final NhtsaVehicleService _nhtsaService =
      NhtsaVehicleService();

  final VehicleService _vehicleService =
      VehicleService();

  List<String> _vehicleBrands = [];

  List<NhtsaVehicleItem> _vehicleModels = [];

  String? _selectedBrand;

  NhtsaVehicleItem? _selectedVehicleModel;

  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
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

    _loadVehicleBrands();
  }

  Future<void> _loadVehicleBrands() async {
    try {
      final List<String> brands =
          await _nhtsaService.getBrands(
        widget.vehicleType,
      );

      String? selectedBrand;

      if (widget.existingVehicle != null) {
        final String existingBrand =
            widget.existingVehicle!.brand.trim();

        for (final String brand in brands) {
          if (brand.toLowerCase() ==
              existingBrand.toLowerCase()) {
            selectedBrand = brand;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _vehicleBrands = brands;
        _selectedBrand = selectedBrand;
        _isLoadingBrands = false;
      });

      if (selectedBrand != null) {
        await _loadModelsForBrand(
          selectedBrand,
          selectExistingModel: true,
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingBrands = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load vehicle brands.',
          ),
        ),
      );
    }
  }

  Future<void> _loadModelsForBrand(
    String brand, {
    bool selectExistingModel = false,
  }) async {
    setState(() {
      _isLoadingModels = true;
      _vehicleModels = [];
      _selectedVehicleModel = null;
    });

    try {
      final List<NhtsaVehicleItem> models =
          await _nhtsaService.getModels(
        brand,
      );

      NhtsaVehicleItem? selectedModel;

      if (selectExistingModel &&
          widget.existingVehicle != null) {
        final String existingModel =
            widget.existingVehicle!.model.trim();

        for (final NhtsaVehicleItem item in models) {
          if (item.model.toLowerCase() ==
              existingModel.toLowerCase()) {
            selectedModel = item;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _vehicleModels = models;
        _selectedVehicleModel = selectedModel;
        _isLoadingModels = false;
      });
    } catch (_) {
      if (!mounted) return;

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

    final NhtsaVehicleItem? selectedModel =
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
      createdDate:
          widget.existingVehicle?.createdDate ??
              DateTime.now(),
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

                _buildBrandField(),

                const SizedBox(height: 16),

                _buildModelField(),

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

  Widget _buildBrandField() {
    if (_isLoadingBrands) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Brand *',
          prefixIcon: Icon(
            Icons.business_outlined,
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

    if (_vehicleBrands.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Brand *',
          prefixIcon: Icon(
            Icons.business_outlined,
          ),
        ),
        child: Text(
          'No vehicle brands available',
          style: TextStyle(
            color: AppTheme.secondaryText,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedBrand,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Brand *',
        prefixIcon: Icon(
          Icons.business_outlined,
        ),
      ),
      items: _vehicleBrands.map(
        (String brand) {
          return DropdownMenuItem<String>(
            value: brand,
            child: Text(
              brand,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (String? value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedBrand = value;
          _selectedVehicleModel = null;
          _vehicleModels = [];
        });

        _loadModelsForBrand(value);
      },
      validator: (String? value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please select a brand';
        }

        return null;
      },
    );
  }

  Widget _buildModelField() {
    if (_selectedBrand == null) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Model *',
          prefixIcon: Icon(
            Icons.directions_car_outlined,
          ),
        ),
        child: Text(
          'Select a brand first',
          style: TextStyle(
            color: AppTheme.secondaryText,
          ),
        ),
      );
    }

    if (_isLoadingModels) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Model *',
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

    if (_vehicleModels.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Model *',
          prefixIcon: Icon(
            Icons.directions_car_outlined,
          ),
        ),
        child: Text(
          'No models available for this brand',
          style: TextStyle(
            color: AppTheme.secondaryText,
          ),
        ),
      );
    }

    return DropdownButtonFormField<NhtsaVehicleItem>(
      initialValue: _selectedVehicleModel,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Model *',
        prefixIcon: Icon(
          Icons.directions_car_outlined,
        ),
      ),
      items: _vehicleModels.map(
        (NhtsaVehicleItem item) {
          return DropdownMenuItem<NhtsaVehicleItem>(
            value: item,
            child: Text(
              item.model,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (NhtsaVehicleItem? value) {
        setState(() {
          _selectedVehicleModel = value;
        });
      },
      validator: (NhtsaVehicleItem? value) {
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