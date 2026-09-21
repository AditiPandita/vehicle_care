import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/service_log_model.dart';
import '../../models/spare_part_model.dart';
import '../../services/service_log_service.dart';
import '../../services/spare_parts_service.dart';

class AddServiceLogScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleBrand;
  final String vehicleModel;
  final String registrationNumber;

  const AddServiceLogScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.registrationNumber,
  });

  @override
  State<AddServiceLogScreen> createState() =>
      _AddServiceLogScreenState();
}

class _AddServiceLogScreenState
    extends State<AddServiceLogScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _odometerController =
      TextEditingController();

  final TextEditingController _serviceCenterController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  final TextEditingController _searchController =
      TextEditingController();

  final SparePartsService _sparePartsService =
      SparePartsService();

  final ServiceLogService _serviceLogService =
      ServiceLogService();

  DateTime _selectedDate = DateTime.now();

  List<SparePart> _availableParts = [];

  final List<SparePart> _selectedParts = [];

  bool _isSearchingParts = false;
  bool _isSaving = false;

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _dateController.text =
        _formatDate(_selectedDate);

    _searchController.addListener(
      _onSearchChanged,
    );

    _loadParts();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();

    _dateController.dispose();
    _odometerController.dispose();
    _serviceCenterController.dispose();
    _notesController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

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

  // ============================================================
  // SPARE PARTS SEARCH
  // ============================================================

  void _onSearchChanged() {
    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 350),
      () {
        _loadParts(
          query: _searchController.text,
        );
      },
    );
  }

  Future<void> _loadParts({
    String query = '',
  }) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSearchingParts = true;
    });

    try {
      final List<SparePart> parts =
          await _sparePartsService.searchParts(
        brand: widget.vehicleBrand,
        model: widget.vehicleModel,
        query: query,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _availableParts = parts;
        _isSearchingParts = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _availableParts = [];
        _isSearchingParts = false;
      });
    }
  }

  void _addPart(SparePart part) {
    final bool alreadySelected =
        _selectedParts.any(
      (selectedPart) =>
          selectedPart.id == part.id,
    );

    if (alreadySelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This spare part is already added.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _selectedParts.add(part);
    });
  }

  void _removePart(SparePart part) {
    setState(() {
      _selectedParts.removeWhere(
        (selectedPart) =>
            selectedPart.id == part.id,
      );
    });
  }

  double get _sparePartsTotal {
    return _selectedParts.fold(
      0,
      (total, part) => total + part.price,
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveServiceLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? odometerReading =
        double.tryParse(
      _odometerController.text.trim(),
    );

    if (odometerReading == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      /*
       * Your existing ServiceLog model expects:
       *
       * odometerReading
       * labourCost
       * sparePartsCost
       * spareParts = List<String>
       *
       * Labour cost is intentionally 0 because
       * labour cost is not part of your UI.
       */

      final ServiceLog serviceLog =
          ServiceLog(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),

        vehicleId: widget.vehicleId,

        serviceDate: _selectedDate,

        odometerReading: odometerReading,

        serviceCenter:
            _serviceCenterController.text.trim(),

        notes:
            _notesController.text.trim(),

        spareParts: _selectedParts
            .map(
              (part) => part.name,
            )
            .toList(),

        sparePartsCost: _sparePartsTotal,

        labourCost: 0,
      );

      await _serviceLogService
          .saveServiceLog(serviceLog);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service log added successfully.',
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
            'Unable to save service log.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Service Log',
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

            const SizedBox(height: 22),

            const Text(
              'Service Details',
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

            _buildServiceCenterField(),

            const SizedBox(height: 14),

            _buildNotesField(),

            const SizedBox(height: 26),

            const Text(
              'Spare Parts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Search and select the spare parts used during service.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),

            const SizedBox(height: 14),

            _buildSearchField(),

            const SizedBox(height: 14),

            _buildAvailableParts(),

            const SizedBox(height: 22),

            _buildSelectedParts(),

            const SizedBox(height: 22),

            _buildCostCard(),

            const SizedBox(height: 28),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VEHICLE CARD
  // ============================================================

  Widget _buildVehicleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
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
              Icons.directions_car_outlined,
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
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.registrationNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Date',
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
            hintText: 'Select service date',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ODOMETER
  // ============================================================

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
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
            hintText: 'Enter current odometer',
            prefixIcon: Icon(
              Icons.speed_outlined,
              color: AppTheme.primaryColor,
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

            if (number == null || number < 0) {
              return 'Enter a valid odometer';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // SERVICE CENTER
  // ============================================================

  Widget _buildServiceCenterField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Center',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller:
              _serviceCenterController,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            hintText:
                'Enter service center name',
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

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
                'Add any additional service notes...',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search spare parts...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppTheme.primaryColor,
        ),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
      ),
    );
  }

  // ============================================================
  // AVAILABLE PARTS
  // ============================================================

  Widget _buildAvailableParts() {
    if (_isSearchingParts) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_availableParts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off,
              size: 34,
              color: AppTheme.secondaryText,
            ),
            SizedBox(height: 10),
            Text(
              'No spare parts found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _availableParts.map(
        (SparePart part) {
          final bool isSelected =
              _selectedParts.any(
            (selectedPart) =>
                selectedPart.id == part.id,
          );

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(17),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color:
                        AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppTheme.darkText,
                        ),
                      ),

                      if (part.partNumber
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Part No: '
                          '${part.partNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                AppTheme.secondaryText,
                          ),
                        ),
                      ],

                      const SizedBox(height: 5),

                      Text(
                        '₹${part.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                OutlinedButton(
                  onPressed: isSelected
                      ? null
                      : () {
                          _addPart(part);
                        },
                  child: Text(
                    isSelected ? 'Added' : 'Add',
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // SELECTED PARTS
  // ============================================================

  Widget _buildSelectedParts() {
    if (_selectedParts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Spare Parts Cost',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: _selectedParts.map(
              (SparePart part) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color:
                            AppTheme.primaryColor,
                        size: 20,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          part.name,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w500,
                            color:
                                AppTheme.darkText,
                          ),
                        ),
                      ),

                      Text(
                        '₹${part.price.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.darkText,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          _removePart(part);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 19,
                        ),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COST
  // ============================================================

  Widget _buildCostCard() {
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
          const Text(
            'Total Spare Parts Cost',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),

          const Spacer(),

          Text(
            '₹${_sparePartsTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed:
          _isSaving ? null : _saveServiceLog,
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
              'Save Service Log',
            ),
    );
  }

  // ============================================================
  // HELPER
  // ============================================================

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