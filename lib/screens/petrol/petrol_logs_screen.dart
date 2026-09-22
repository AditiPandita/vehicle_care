import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/petrol_log_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/petrol_log_service.dart';
import '../../services/vehicle_service.dart';
import 'add_petrol_log_screen.dart';

class PetrolLogsScreen extends StatefulWidget {
  final String vehicleId;

  const PetrolLogsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<PetrolLogsScreen> createState() =>
      _PetrolLogsScreenState();
}

class _PetrolLogsScreenState
    extends State<PetrolLogsScreen> {
  final VehicleService _vehicleService =
      VehicleService();

  final PetrolLogService _petrolLogService =
      PetrolLogService();

  Vehicle? _vehicle;

  List<PetrolLog> _petrolLogs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<Vehicle> vehicles =
          await _vehicleService.getVehicles();

      Vehicle? foundVehicle;

      for (final Vehicle vehicle in vehicles) {
        if (vehicle.id == widget.vehicleId) {
          foundVehicle = vehicle;
          break;
        }
      }

      final List<PetrolLog> logs =
          await _petrolLogService.getPetrolLogs(
        widget.vehicleId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicle = foundVehicle;
        _petrolLogs = logs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load petrol logs.',
          ),
        ),
      );
    }
  }

  Future<void> _addPetrolLog() async {
    final Vehicle? vehicle = _vehicle;

    if (vehicle == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPetrolLogScreen(
          vehicleId: vehicle.id,
          vehicleBrand: vehicle.brand,
          vehicleModel: vehicle.model,
          registrationNumber:
              vehicle.registrationNumber,
        ),
      ),
    );

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Petrol Logs',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_vehicle == null) {
      return const Center(
        child: Text(
          'Vehicle not found',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.secondaryText,
          ),
        ),
      );
    }

    // ==========================================================
    // NO PETROL LOGS
    // ==========================================================

    if (_petrolLogs.isEmpty) {
      return _buildEmptyState();
    }

    // ==========================================================
    // PETROL LOGS EXIST
    // ==========================================================

    return Column(
      children: [
        // FULL WIDTH ADD BUTTON
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12,
          ),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _addPetrolLog,
              icon: const Icon(
                Icons.add,
                size: 20,
              ),
              label: const Text(
                'Add Petrol Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),

        // PETROL LOG HISTORY
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              itemCount:
                  _petrolLogs.length,
              itemBuilder:
                  (context, index) {
                final PetrolLog log =
                    _petrolLogs[index];

                return _buildPetrolLogCard(log);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          28,
        ),
        child: Column(
          children: [
            const Spacer(),

            Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                color:
                    AppTheme.primaryLight,
                borderRadius:
                    BorderRadius.circular(95),
              ),
              child: const Icon(
                Icons.local_gas_station,
                size: 100,
                color:
                    AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'No Petrol Logs Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Keep track of your fuel purchases, '
              'fuel quantity and petrol expenses '
              'by adding your first petrol record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color:
                    AppTheme.secondaryText,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addPetrolLog,
                icon: const Icon(
                  Icons.add,
                  size: 21,
                ),
                label: const Text(
                  'Add Petrol Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppTheme.primaryColor,
                  foregroundColor:
                      Colors.white,
                  elevation: 2,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PETROL LOG CARD
  // ==========================================================

  Widget _buildPetrolLogCard(
    PetrolLog log,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
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
                  Icons.local_gas_station,
                  color:
                      AppTheme.primaryColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Petrol',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        log.petrolDate,
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '₹${log.totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ODOMETER
          _buildInfoRow(
            Icons.speed_outlined,
            'Odometer',
            '${_formatNumber(log.odometerReading)} km',
          ),

          const SizedBox(height: 11),

          // FUEL QUANTITY
          _buildInfoRow(
            Icons.local_gas_station_outlined,
            'Fuel',
            '${_formatNumber(log.fuelQuantity)} L',
          ),

          const SizedBox(height: 11),

          // PRICE
          _buildInfoRow(
            Icons.currency_rupee,
            'Price / Litre',
            '₹${log.pricePerLitre.toStringAsFixed(2)}',
          ),

          // PETROL STATION
          if (log.petrolStation
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 11),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Petrol Station',
              log.petrolStation,
            ),
          ],

          // NOTES
          if (log.notes
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              log.notes,
              style: const TextStyle(
                fontSize: 13,
                color:
                    AppTheme.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // INFO ROW
  // ==========================================================

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color:
                AppTheme.secondaryText,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DATE
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

  // ==========================================================
  // NUMBER
  // ==========================================================

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}