import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/petrol_log_model.dart';
import '../../services/petrol_log_service.dart';

class AddPetrolLogScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleBrand;
  final String vehicleModel;
  final String registrationNumber;

  const AddPetrolLogScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.registrationNumber,
  });

  @override
  State<AddPetrolLogScreen> createState() =>
      _AddPetrolLogScreenState();
}

class _AddPetrolLogScreenState
    extends State<AddPetrolLogScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _odometerController =
      TextEditingController();

  final TextEditingController _fuelQuantityController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  final TextEditingController _stationController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  final PetrolLogService _petrolLogService =
      PetrolLogService();

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _dateController.text =
        _formatDate(_selectedDate);

    _fuelQuantityController.addListener(
      _updateTotal,
    );

    _priceController.addListener(
      _updateTotal,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _odometerController.dispose();
    _fuelQuantityController.dispose();
    _priceController.dispose();
    _stationController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _updateTotal() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  double get _totalCost {
    final double quantity =
        double.tryParse(
              _fuelQuantityController.text
                  .trim(),
            ) ??
            0;

    final double price =
        double.tryParse(
              _priceController.text.trim(),
            ) ??
            0;

    return quantity * price;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;

      _dateController.text =
          _formatDate(pickedDate);
    });
  }

  Future<void> _savePetrolLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? odometerReading =
        double.tryParse(
      _odometerController.text.trim(),
    );

    final double? fuelQuantity =
        double.tryParse(
      _fuelQuantityController.text.trim(),
    );

    final double? pricePerLitre =
        double.tryParse(
      _priceController.text.trim(),
    );

    if (odometerReading == null ||
        fuelQuantity == null ||
        pricePerLitre == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final PetrolLog petrolLog =
          PetrolLog(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        vehicleId: widget.vehicleId,
        petrolDate: _selectedDate,
        odometerReading: odometerReading,
        fuelQuantity: fuelQuantity,
        pricePerLitre: pricePerLitre,
        totalCost: _totalCost,
        petrolStation:
            _stationController.text.trim(),
        notes: _notesController.text.trim(),
      );

      await _petrolLogService.savePetrolLog(
        petrolLog,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Petrol log added successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
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
            'Unable to save petrol log.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Petrol Log',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            35,
          ),
          children: [
            _buildVehicleCard(),

            const SizedBox(height: 24),

            const Text(
              'Petrol Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 14),

            _buildDateField(),

            const SizedBox(height: 14),

            _buildOdometerField(),

            const SizedBox(height: 14),

            _buildFuelQuantityField(),

            const SizedBox(height: 14),

            _buildPriceField(),

            const SizedBox(height: 20),

            _buildTotalCard(),

            const SizedBox(height: 22),

            _buildStationField(),

            const SizedBox(height: 14),

            _buildNotesField(),

            const SizedBox(height: 30),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // VEHICLE CARD
  // ==========================================================

  Widget _buildVehicleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_gas_station_outlined,
              color: AppTheme.primaryColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.vehicleBrand} '
                  '${widget.vehicleModel}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.registrationNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                        AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Petrol Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: const InputDecoration(
            hintText: 'Select petrol date',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color:
                  AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ODOMETER
  // ==========================================================

  Widget _buildOdometerField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Odometer Reading',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppTheme.darkText,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _odometerController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            hintText:
                'Enter current odometer',
            prefixIcon: Icon(
              Icons.speed_outlined,
              color:
                  AppTheme.primaryColor,
            ),
            suffixText: 'km',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Odometer is required';
            }

            final double? number =
                double.tryParse(
              value.trim(),
            );

            if (number == null ||
                number < 0) {
              return 'Enter a valid odometer';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ==========================================================
  // FUEL QUANTITY
  // ==========================================================

  Widget _buildFuelQuantityField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Fuel Quantity',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppTheme.darkText,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:
              _fuelQuantityController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            hintText:
                'Enter fuel quantity',
            prefixIcon: Icon(
              Icons.local_gas_station_outlined,
              color:
                  AppTheme.primaryColor,
            ),
            suffixText: 'L',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Fuel quantity is required';
            }

            final double? number =
                double.tryParse(
              value.trim(),
            );

            if (number == null ||
                number <= 0) {
              return 'Enter a valid quantity';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Price per Litre',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppTheme.darkText,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            hintText:
                'Enter price per litre',
            prefixText: '₹ ',
            prefixIcon: Icon(
              Icons.currency_rupee,
              color:
                  AppTheme.primaryColor,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Price is required';
            }

            final double? number =
                double.tryParse(
              value.trim(),
            );

            if (number == null ||
                number <= 0) {
              return 'Enter a valid price';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ==========================================================
  // TOTAL
  // ==========================================================

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Cost',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        AppTheme.secondaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fuel amount',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${_totalCost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PETROL STATION
  // ==========================================================

  Widget _buildStationField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Petrol Station',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _stationController,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            hintText:
                'Enter petrol station name',
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color:
                  AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // NOTES
  // ==========================================================

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          textCapitalization:
              TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText:
                'Add any additional notes...',
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed:
            _isSaving ? null : _savePetrolLog,
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Petrol Log',
              ),
      ),
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}