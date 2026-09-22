import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/service_log_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/service_log_service.dart';
import '../../services/vehicle_service.dart';
import 'add_service_log_screen.dart';

class ServiceLogsScreen extends StatefulWidget {
  final String vehicleId;

  const ServiceLogsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<ServiceLogsScreen> createState() =>
      _ServiceLogsScreenState();
}

class _ServiceLogsScreenState
    extends State<ServiceLogsScreen> {
  final VehicleService _vehicleService =
      VehicleService();

  final ServiceLogService _serviceLogService =
      ServiceLogService();

  Vehicle? _vehicle;

  List<ServiceLog> _serviceLogs = [];

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

      final List<ServiceLog> logs =
          await _serviceLogService.getServiceLogs(
        widget.vehicleId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicle = foundVehicle;
        _serviceLogs = logs;
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
            'Unable to load service logs.',
          ),
        ),
      );
    }
  }

  Future<void> _addServiceLog() async {
    final Vehicle? vehicle = _vehicle;

    if (vehicle == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceLogScreen(
          vehicleId: vehicle.id,
          vehicleBrand: vehicle.brand,
          vehicleModel: vehicle.model,
          registrationNumber:
              vehicle.registrationNumber,
              vehicleType: vehicle.vehicleType,
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
          'Service Logs',
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
    // NO SERVICE LOGS
    // ==========================================================

    if (_serviceLogs.isEmpty) {
      return _buildEmptyState();
    }

    // ==========================================================
    // SERVICE LOGS AVAILABLE
    // ==========================================================

return Column(
  children: [
    // FULL WIDTH ADD SERVICE LOG BAR
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
          onPressed: _addServiceLog,
          icon: const Icon(
            Icons.add,
            size: 20,
          ),
          label: const Text(
            'Add Service Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ),

    // SERVICE LOGS BELOW
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
          itemCount: _serviceLogs.length,
          itemBuilder: (
            context,
            index,
          ) {
            final ServiceLog log =
                _serviceLogs[index];

            return _buildServiceLogCard(log);
          },
        ),
      ),
    ),
  ],
);
  }

  // ==========================================================
  // FULL SCREEN EMPTY STATE
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

            // ILLUSTRATION
            Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius:
                    BorderRadius.circular(95),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.garage_outlined,
                    size: 105,
                    color:
                        AppTheme.primaryColor
                            .withValues(alpha: 0.85),
                  ),
                  Positioned(
                    bottom: 32,
                    child: Icon(
                      Icons.directions_car,
                      size: 58,
                      color:
                          AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              'No Service Logs Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            const Text(
              'Keep track of your vehicle maintenance, '
              'service history and spare parts costs '
              'by adding your first service record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.secondaryText,
              ),
            ),

            const Spacer(),

            // ADD SERVICE LOG BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addServiceLog,
                icon: const Icon(
                  Icons.add,
                  size: 21,
                ),
                label: const Text(
                  'Add Service Log',
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
                        BorderRadius.circular(16),
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
  // SERVICE LOG CARD
  // ==========================================================

  Widget _buildServiceLogCard(
    ServiceLog log,
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
                  Icons.build_outlined,
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
                      'Service',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        log.serviceDate,
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
                '₹${log.totalCost.toStringAsFixed(0)}',
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

          _buildInfoRow(
            Icons.speed_outlined,
            'Odometer',
            '${_formatNumber(log.odometerReading)} km',
          ),

          if (log.serviceCenter
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 11),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Service Center',
              log.serviceCenter,
            ),
          ],

          if (log.spareParts.isNotEmpty) ...[
            const SizedBox(height: 17),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Spare Parts',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 9),

            ...log.spareParts.map(
              (String partName) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 7,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 5,
                        color:
                            AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          partName,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            color:
                                AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Spacer(),
                Text(
                  'Spare Parts: '
                  '₹${log.sparePartsCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ],

          if (log.notes
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 12),
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

    return value.toStringAsFixed(1);
  }
}