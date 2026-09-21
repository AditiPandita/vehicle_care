import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import 'add_vehicle_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState
    extends State<VehicleDetailsScreen> {
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _editVehicle() async {
    final updatedVehicle =
        await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleScreen(
          vehicleType: _vehicle.vehicleType,
          existingVehicle: _vehicle,
        ),
      ),
    );

    if (updatedVehicle == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _vehicle = updatedVehicle;
    });

    Navigator.pop(context, updatedVehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildDetailsCard(),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _editVehicle,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _vehicle.vehicleType == '2 Wheeler'
                  ? Icons.two_wheeler
                  : Icons.directions_car_outlined,
              color: AppTheme.primaryColor,
              size: 34,
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
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _vehicle.registrationNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.branding_watermark_outlined,
            title: 'Brand',
            value: _vehicle.brand,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.directions_car_outlined,
            title: 'Model',
            value: _vehicle.model,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.category_outlined,
            title: 'Vehicle Type',
            value: _vehicle.vehicleType,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.confirmation_number_outlined,
            title: 'Plate Number',
            value: _vehicle.registrationNumber,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            title: 'Manufacturing Year',
            value: _vehicle.year.toString(),
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.speed_outlined,
            title: 'Current Odometer',
            value:
                '${_formatOdometer(_vehicle.currentOdometer)} km',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: highlight
                  ? AppTheme.primaryLight
                  : const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 21,
              color: highlight
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryText,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: highlight
                        ? AppTheme.primaryColor
                        : AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: Colors.grey.shade100,
    );
  }

  String _formatOdometer(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}