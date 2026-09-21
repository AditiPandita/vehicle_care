import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ProfileDrawer extends StatelessWidget {
  final String userName;

  const ProfileDrawer({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                30,
                24,
                28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 38,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'VehicleCare Profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Profile Option
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile section will be added later.',
                    ),
                  ),
                );
              },
            ),

            // Settings Option
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Settings section will be added later.',
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'VehicleCare',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      leading: Icon(
        icon,
        color: AppTheme.darkText,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppTheme.darkText,
        ),
      ),
      onTap: onTap,
    );
  }
}