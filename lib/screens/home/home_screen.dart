import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../profile/profile_drawer.dart';
import '../vehicles/vehicle_screen.dart';
import '../reminders/reminders_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(
        userName: userName,
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu_rounded,
                size: 28,
              ),
              color: AppTheme.darkText,
            );
          },
        ),
        title: const Text(
          'VehicleCare',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName 👋',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Manage all your vehicles in one place.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.secondaryText,
                ),
              ),

              const SizedBox(height: 32),
                  _RemindersCard(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RemindersScreen(),
      ),
    );
  },
),

const SizedBox(height: 28),
              const Text(
                'Your Vehicles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),

              const SizedBox(height: 16),

              _VehicleTypeCard(
                title: '2 Wheeler',
                subtitle: 'Manage your bikes and scooters',
                icon: Icons.two_wheeler_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VehicleScreen(
                        vehicleType: '2 Wheeler',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              _VehicleTypeCard(
                title: '4 Wheeler',
                subtitle: 'Manage your cars',
                icon: Icons.directions_car_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VehicleScreen(
                        vehicleType: '4 Wheeler',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppTheme.secondaryText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Row(
                      children: [
                        Text(
                          'View Vehicles',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _RemindersCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RemindersCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Reminders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Check your upcoming vehicle services',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}