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
      return Center(
        child: ElevatedButton.icon(
          onPressed: _addServiceLog,
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            'Add Service Log',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              175,
              52,
            ),
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
      );
    }

    // ==========================================================
    // SERVICE LOGS EXIST
    // ==========================================================

    return Column(
      children: [
        // TOP BAR
        Container(
          width: double.infinity,
          height: 86,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          color: Colors.white,
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _addServiceLog,
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
              label: const Text(
                'Add Service Log',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  150,
                  48,
                ),
                backgroundColor:
                    AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ),

        // SERVICE LOG LIST
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: _loadData,
            child: ListView.builder(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              itemCount:
                  _serviceLogs.length,
              itemBuilder:
                  (context, index) {
                final ServiceLog log =
                    _serviceLogs[index];

                return _buildServiceLogCard(
                  log,
                );
              },
            ),
          ),
        ),
      ],
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
      margin:
          const EdgeInsets.only(bottom: 16),
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

          // ODOMETER
          _buildInfoRow(
            Icons.speed_outlined,
            'Odometer',
            '${_formatNumber(log.odometerReading)} km',
          ),

          // SERVICE CENTER
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

          // SPARE PARTS
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

          // NOTES
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

  // ==========================================================
  // NUMBER FORMAT
  // ==========================================================

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}