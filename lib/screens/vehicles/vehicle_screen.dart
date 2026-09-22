import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../services/petrol_log_service.dart';
import '../../services/vehicle_service.dart';
import '../activity/recent_activity_screen.dart';
import '../petrol/petrol_logs_screen.dart';
import '../service/service_logs_screen.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class VehicleScreen extends StatefulWidget {
  final String vehicleType;

  const VehicleScreen({
    super.key,
    required this.vehicleType,
  });

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final List<Vehicle> allVehicles =
          await _vehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = allVehicles
            .where(
              (vehicle) =>
                  vehicle.vehicleType == widget.vehicleType,
            )
            .toList();

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load vehicles.'),
        ),
      );
    }
  }

  Future<void> _addVehicle() async {
    final Vehicle? result =
        await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleScreen(
          vehicleType: widget.vehicleType,
        ),
      ),
    );

    if (result != null) {
      await _loadVehicles();
    }
  }

  Future<void> _openVehicleDashboard(
    Vehicle vehicle,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDashboard(
          vehicle: vehicle,
          onVehicleUpdated: _loadVehicles,
        ),
      ),
    );

    await _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleType),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
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

    if (_vehicles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadVehicles,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ),
        children: [
          Text(
            '${_vehicles.length} '
            '${_vehicles.length == 1 ? 'Vehicle' : 'Vehicles'}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          ..._vehicles.map(_buildVehicleCard),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final bool isTwoWheeler =
        vehicle.vehicleType == '2 Wheeler';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openVehicleDashboard(vehicle),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isTwoWheeler
                        ? Icons.two_wheeler
                        : Icons.directions_car_outlined,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        vehicle.registrationNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${vehicle.year} • '
                        '${_formatOdometer(vehicle.currentOdometer)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isTwoWheeler =
        widget.vehicleType == '2 Wheeler';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTwoWheeler
                    ? Icons.two_wheeler
                    : Icons.directions_car_outlined,
                size: 42,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No ${widget.vehicleType}s added',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your vehicle to start tracking its details, '
              'service and petrol records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(190, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOdometer(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

// ============================================================
// VEHICLE DASHBOARD
// ============================================================

class VehicleDashboard extends StatefulWidget {
  final Vehicle vehicle;
  final Future<void> Function() onVehicleUpdated;

  const VehicleDashboard({
    super.key,
    required this.vehicle,
    required this.onVehicleUpdated,
  });

  @override
  State<VehicleDashboard> createState() =>
      _VehicleDashboardState();
}

class _VehicleDashboardState
    extends State<VehicleDashboard> {
  late Vehicle _vehicle;

  String _mileage = '-- km/L';

  final VehicleService _vehicleService =
      VehicleService();

  final PetrolLogService _petrolLogService =
      PetrolLogService();

  @override
  void initState() {
    super.initState();

    _vehicle = widget.vehicle;

    _loadMileage();
  }

  // ==========================================================
  // MILEAGE CALCULATION
  // ==========================================================

  Future<void> _loadMileage() async {
    try {
      final logs =
          await _petrolLogService.getPetrolLogs(
        _vehicle.id,
      );

      if (!mounted) return;

      // At least two petrol logs are required
      // to calculate mileage.
      if (logs.length < 2) {
        setState(() {
          _mileage = '-- km/L';
        });
        return;
      }

      // PetrolLogService returns logs newest first.
      final latestLog = logs[0];
      final previousLog = logs[1];

      final double distance =
          latestLog.odometerReading -
          previousLog.odometerReading;

      final double fuelUsed =
          latestLog.fuelQuantity;

      if (distance <= 0 || fuelUsed <= 0) {
        setState(() {
          _mileage = '-- km/L';
        });
        return;
      }

      final double mileage =
          distance / fuelUsed;

      setState(() {
        _mileage =
            '${mileage.toStringAsFixed(1)} km/L';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _mileage = '-- km/L';
      });
    }
  }

  Future<void> _openVehicleDetails() async {
    final Vehicle? updatedVehicle =
        await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDetailsScreen(
          vehicle: _vehicle,
        ),
      ),
    );

    if (updatedVehicle == null) {
      return;
    }

    await _vehicleService.updateVehicle(
      updatedVehicle,
    );

    if (!mounted) return;

    setState(() {
      _vehicle = updatedVehicle;
    });

    await widget.onVehicleUpdated();
  }

  void _showOdometer() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Current Odometer: '
          '${_formatOdometer(_vehicle.currentOdometer)} km',
        ),
      ),
    );
  }

  // ==========================================================
  // PETROL LOGS
  // ==========================================================

  Future<void> _openPetrolLogs() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetrolLogsScreen(
          vehicleId: _vehicle.id,
        ),
      ),
    );

    // Recalculate mileage when returning
    // from Petrol Logs.
    await _loadMileage();
  }

  // ==========================================================
  // RECENT ACTIVITY
  // ==========================================================

  void _openRecentActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecentActivityScreen(
          vehicleId: _vehicle.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle.displayName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildVehicleHeader(),

            const SizedBox(height: 20),

            _buildStatsCard(),

            const SizedBox(height: 24),

            const Text(
              'Vehicle Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 14),

            _buildFeatureGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHeader() {
    final bool isTwoWheeler =
        _vehicle.vehicleType == '2 Wheeler';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              isTwoWheeler
                  ? Icons.two_wheeler
                  : Icons.directions_car_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _vehicle.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _vehicle.registrationNumber,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.speed_outlined,
              title: 'Odometer',
              value:
                  '${_formatOdometer(_vehicle.currentOdometer)} km',
            ),
          ),

          Container(
            height: 50,
            width: 1,
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: _buildStatItem(
              icon:
                  Icons.local_gas_station_outlined,
              title: 'Mileage',
              value: _mileage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 25,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.18,
      children: [
        _buildFeatureCard(
          icon:
              Icons.directions_car_outlined,
          title: 'Vehicle Details',
          subtitle: 'View & edit details',
          onTap: _openVehicleDetails,
        ),

        _buildFeatureCard(
          icon: Icons.speed_outlined,
          title: 'Odometer',
          subtitle: 'Current reading',
          onTap: _showOdometer,
        ),

        _buildFeatureCard(
          icon: Icons.build_outlined,
          title: 'Service Logs',
          subtitle: 'Service history',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ServiceLogsScreen(
                  vehicleId: _vehicle.id,
                ),
              ),
            );
          },
        ),

        _buildFeatureCard(
          icon:
              Icons.local_gas_station_outlined,
          title: 'Petrol Logs',
          subtitle: 'Fuel history',
          onTap: _openPetrolLogs,
        ),

        _buildFeatureCard(
          icon: Icons.history,
          title: 'Recent Activity',
          subtitle: 'Latest updates',
          onTap: _openRecentActivity,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOdometer(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}