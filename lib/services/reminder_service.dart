import '../models/service_log_model.dart';
import '../models/vehicle_model.dart';
import 'service_log_service.dart';
import 'service_reminder_calculator.dart';

class ReminderService {
  final ServiceLogService _serviceLogService =
      ServiceLogService();

  Future<ServiceReminderResult> getReminder(
    Vehicle vehicle,
  ) async {
    final ServiceLog? latestService =
        await _serviceLogService.getLatestServiceLog(
      vehicle.id,
    );

    return ServiceReminderCalculator.calculate(
      vehicle: vehicle,
      lastService: latestService,
    );
  }
}