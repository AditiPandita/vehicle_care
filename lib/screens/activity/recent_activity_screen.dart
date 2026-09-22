import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';

class RecentActivityScreen extends StatefulWidget {
  final String vehicleId;

  const RecentActivityScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<RecentActivityScreen> createState() =>
      _RecentActivityScreenState();
}

class _RecentActivityScreenState
    extends State<RecentActivityScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<_ActivityItem> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final List<_ActivityItem> activities = [];

      // ----------------------------------------------------------
      // LOAD SERVICE LOGS
      // ----------------------------------------------------------

      final String? serviceData =
          preferences.getString('service_logs');

      if (serviceData != null &&
          serviceData.isNotEmpty) {
        final dynamic decodedServiceData =
            jsonDecode(serviceData);

        if (decodedServiceData is List) {
          for (final dynamic item
              in decodedServiceData) {
            if (item is! Map) {
              continue;
            }

            final Map<String, dynamic> data =
                Map<String, dynamic>.from(item);

            final String vehicleId =
                data['vehicleId']?.toString() ?? '';

            if (vehicleId != widget.vehicleId) {
              continue;
            }

            final DateTime serviceDate =
                DateTime.tryParse(
                      data['serviceDate']?.toString() ?? '',
                    ) ??
                    DateTime.now();

            final double totalCost =
                _parseDouble(
              data['totalCost'],
              fallback: _parseDouble(
                    data['sparePartsCost'],
                  ) +
                  _parseDouble(
                    data['labourCost'],
                  ),
            );

            final double odometer =
                _parseDouble(
              data['odometerReading'],
            );

            final String serviceCenter =
                data['serviceCenter']?.toString() ?? '';

            activities.add(
              _ActivityItem(
                type: _ActivityType.service,
                date: serviceDate,
                title: 'Service Completed',
                subtitle: serviceCenter.isEmpty
                    ? 'Vehicle service'
                    : serviceCenter,
                amount: totalCost,
                odometer: odometer,
                icon: Icons.build_outlined,
              ),
            );
          }
        }
      }

      // ----------------------------------------------------------
      // LOAD PETROL LOGS
      // ----------------------------------------------------------

      final String? petrolData =
          preferences.getString('petrol_logs');

      if (petrolData != null &&
          petrolData.isNotEmpty) {
        final dynamic decodedPetrolData =
            jsonDecode(petrolData);

        if (decodedPetrolData is List) {
          for (final dynamic item
              in decodedPetrolData) {
            if (item is! Map) {
              continue;
            }

            final Map<String, dynamic> data =
                Map<String, dynamic>.from(item);

            final String vehicleId =
                data['vehicleId']?.toString() ?? '';

            if (vehicleId != widget.vehicleId) {
              continue;
            }

            final DateTime petrolDate =
                DateTime.tryParse(
                      data['petrolDate']?.toString() ?? '',
                    ) ??
                    DateTime.now();

            final double totalCost =
                _parseDouble(
              data['totalCost'],
            );

            final double odometer =
                _parseDouble(
              data['odometerReading'],
            );

            final double fuelQuantity =
                _parseDouble(
              data['fuelQuantity'],
            );

            final String petrolStation =
                data['petrolStation']?.toString() ?? '';

            activities.add(
              _ActivityItem(
                type: _ActivityType.petrol,
                date: petrolDate,
                title: 'Petrol Filled',
                subtitle: petrolStation.isEmpty
                    ? 'Fuel refill'
                    : petrolStation,
                amount: totalCost,
                odometer: odometer,
                fuelQuantity: fuelQuantity,
                icon: Icons.local_gas_station_outlined,
              ),
            );
          }
        }
      }

      // ----------------------------------------------------------
      // SORT NEWEST FIRST
      // ----------------------------------------------------------

      activities.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load recent activity.';
      });
    }
  }

  double _parseDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    final double? parsed =
        double.tryParse(
      value?.toString() ?? '',
    );

    return parsed ?? fallback;
  }

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

    return '${date.day} ${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activity'),
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

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(
            _activities[index],
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
    _ActivityItem activity,
  ) {
    final bool isService =
        activity.type == _ActivityType.service;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  activity.icon,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${_formatNumber(activity.amount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(activity.date),
                ),
                _buildInfoItem(
                  icon: Icons.speed_outlined,
                  text:
                      '${_formatNumber(activity.odometer)} km',
                ),
                if (!isService &&
                    activity.fuelQuantity != null)
                  _buildInfoItem(
                    icon:
                        Icons.local_gas_station_outlined,
                    text:
                        '${_formatNumber(activity.fuelQuantity!)} L',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppTheme.secondaryText,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(
                Icons.history,
                size: 42,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Recent Activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your service and petrol activities '
              'will appear here.',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadActivities,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ActivityType {
  service,
  petrol,
}

class _ActivityItem {
  final _ActivityType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final double amount;
  final double odometer;
  final double? fuelQuantity;
  final IconData icon;

  const _ActivityItem({
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.odometer,
    required this.icon,
    this.fuelQuantity,
  });
}