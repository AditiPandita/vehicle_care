import '../models/vehicle_model.dart';
import '../models/service_log_model.dart';

class ServiceReminderResult {
  final DateTime dueDate;
  final double dueOdometer;
  final bool isDue;
  final int daysRemaining;
  final double kmRemaining;
  final String reason;

  const ServiceReminderResult({
    required this.dueDate,
    required this.dueOdometer,
    required this.isDue,
    required this.daysRemaining,
    required this.kmRemaining,
    required this.reason,
  });
}

class ServiceReminderCalculator {
  ServiceReminderCalculator._();

  static ServiceReminderResult calculate({
    required Vehicle vehicle,
    ServiceLog? lastService,
  }) {
    final bool isTwoWheeler =
        vehicle.vehicleType == '2 Wheeler';

    final double odometerInterval =
        isTwoWheeler ? 3000 : 10000;

    final int monthsInterval =
        isTwoWheeler ? 6 : 12;

    // --------------------------------------------------
    // BASELINE
    // --------------------------------------------------
    //
    // If the vehicle has service history:
    // use the latest service date and odometer.
    //
    // If there is no service history:
    // use vehicle creation date and current odometer.
    //

    final DateTime baseDate =
        lastService?.serviceDate ??
        vehicle.createdDate;

    final double baseOdometer =
        lastService?.odometerReading ??
        vehicle.currentOdometer;

    // --------------------------------------------------
    // NEXT SERVICE TARGET
    // --------------------------------------------------

    final DateTime dueDate = _addMonths(
      baseDate,
      monthsInterval,
    );

    final double dueOdometer =
        baseOdometer + odometerInterval;

    // --------------------------------------------------
    // CURRENT STATUS
    // --------------------------------------------------

    final DateTime today = DateTime.now();

    final int daysRemaining =
        dueDate.difference(today).inDays;

    final double kmRemaining =
        dueOdometer - vehicle.currentOdometer;

    final bool dateDue =
        !today.isBefore(dueDate);

    final bool odometerDue =
        vehicle.currentOdometer >= dueOdometer;

    final bool isDue =
        dateDue || odometerDue;

    String reason;

    if (dateDue && odometerDue) {
      reason = 'Service due by date and odometer';
    } else if (dateDue) {
      reason = 'Service due by date';
    } else if (odometerDue) {
      reason = 'Service due by odometer';
    } else {
      reason = 'Service not due yet';
    }

    return ServiceReminderResult(
      dueDate: dueDate,
      dueOdometer: dueOdometer,
      isDue: isDue,
      daysRemaining: daysRemaining,
      kmRemaining: kmRemaining,
      reason: reason,
    );
  }

  static DateTime _addMonths(
    DateTime date,
    int months,
  ) {
    final int newMonth =
        date.month + months;

    final int year =
        date.year + ((newMonth - 1) ~/ 12);

    final int month =
        ((newMonth - 1) % 12) + 1;

    final int lastDayOfMonth =
        DateTime(year, month + 1, 0).day;

    final int day =
        date.day > lastDayOfMonth
            ? lastDayOfMonth
            : date.day;

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
    );
  }
}