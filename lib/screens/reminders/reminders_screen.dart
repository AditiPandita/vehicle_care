import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../services/reminder_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/service_reminder_calculator.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final VehicleService _vehicleService =
      VehicleService();

  final ReminderService _reminderService =
      ReminderService();

  List<_VehicleReminder> _reminders = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Vehicle> vehicles =
          await _vehicleService.getVehicles();

      final List<_VehicleReminder> reminders = [];

      for (final Vehicle vehicle in vehicles) {
        final ServiceReminderResult result =
            await _reminderService.getReminder(
          vehicle,
        );

        reminders.add(
          _VehicleReminder(
            vehicle: vehicle,
            result: result,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load service reminders.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Reminders'),
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

    if (_reminders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32,
        ),
        itemCount: _reminders.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return _buildReminderCard(
            _reminders[index],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Vehicles Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a vehicle to start receiving automatic service reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(
    _VehicleReminder reminder,
  ) {
    final Vehicle vehicle =
        reminder.vehicle;

    final ServiceReminderResult result =
        reminder.result;

    final bool isDue = result.isDue;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  vehicle.vehicleType ==
                          '2 Wheeler'
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_rounded,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.registrationNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color:
                            AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(isDue),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            isDue
                ? 'Service Due'
                : 'Service Upcoming',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            result.reason,
            style: TextStyle(
              fontSize: 13,
              color: isDue
                  ? Colors.red.shade700
                  : AppTheme.secondaryText,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.speed_rounded,
                  title: 'Service at',
                  value:
                      '${_formatNumber(result.dueOdometer)} km',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoBox(
                  icon:
                      Icons.calendar_month_rounded,
                  title: 'Due date',
                  value:
                      _formatDate(result.dueDate),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!isDue)
            Row(
              children: [
                Expanded(
                  child: _buildRemainingBox(
                    '${result.daysRemaining}',
                    'days remaining',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRemainingBox(
                    _formatNumber(
                      result.kmRemaining,
                    ),
                    'km remaining',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDue) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: isDue
            ? Colors.red.shade50
            : AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        isDue ? 'DUE' : 'UPCOMING',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isDue
              ? Colors.red.shade700
              : AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                        AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingBox(
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _VehicleReminder {
  final Vehicle vehicle;
  final ServiceReminderResult result;

  const _VehicleReminder({
    required this.vehicle,
    required this.result,
  });
}