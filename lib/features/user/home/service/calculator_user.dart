import 'package:cloud_firestore/cloud_firestore.dart';

class UsageCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> calculateTodayUsage() async {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    double totalWattsUsed = 0.0;
    int totalDurationSeconds = 0;
    int totalUsageLogs = 0;

    try {
      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();

      for (var homeDoc in homesSnapshot.docs) {
        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        for (var equipmentDoc in equipmentSnapshot.docs) {
          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .where('startTime', isGreaterThanOrEqualTo: todayStart)
              .where('startTime', isLessThanOrEqualTo: todayEnd)
              .get();

          totalUsageLogs += usageLogsSnapshot.docs.length;

          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            totalWattsUsed += (data['wattsUsed'] ?? 0.0) as double;
            totalDurationSeconds += (data['durationSeconds'] ?? 0) as int;
          }
        }
      }

      // Calculate kWh (watts to kilowatt-hours)
      double todayKWh = (totalWattsUsed * totalDurationSeconds) / 3600000;

      // Calculate estimated cost (assuming ₹7.50 per kWh - adjust based on your rate)
      double estimatedCost = todayKWh * 7.50;

      return {
        'todayWattsUsed': totalWattsUsed,
        'todayDurationSeconds': totalDurationSeconds,
        'todayKWh': todayKWh,
        'todayUsageLogs': totalUsageLogs,
        'estimatedCost': estimatedCost,
      };
    } catch (e) {
      print('Error calculating today\'s usage: $e');
      return {
        'todayWattsUsed': 0.0,
        'todayDurationSeconds': 0,
        'todayKWh': 0.0,
        'todayUsageLogs': 0,
        'estimatedCost': 0.0,
      };
    }
  }

  // Calculate total usage across all homes and equipment
  Future<Map<String, dynamic>> calculateTotalUsage() async {
    int totalHomes = 0;
    int totalEquipment = 0;
    int totalUsageLogs = 0;
    double totalWattsUsed = 0.0;
    int totalDurationSeconds = 0;

    try {
      // Get all homes
      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();
      totalHomes = homesSnapshot.docs.length;

      // Iterate through each home
      for (var homeDoc in homesSnapshot.docs) {
        // Get all equipment for this home
        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        totalEquipment += equipmentSnapshot.docs.length;

        // Iterate through each equipment
        for (var equipmentDoc in equipmentSnapshot.docs) {
          // Get all usage logs for this equipment
          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              .get();

          totalUsageLogs += usageLogsSnapshot.docs.length;

          // Sum up the usage data
          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            totalWattsUsed += (data['wattsUsed'] ?? 0.0) as double;
            totalDurationSeconds += (data['durationSeconds'] ?? 0) as int;
          }
        }
      }

      // Calculate kWh (watts to kilowatt-hours)
      double totalKWh = (totalWattsUsed * totalDurationSeconds) / 3600000;

      return {
        'totalHomes': totalHomes,
        'totalEquipment': totalEquipment,
        'totalUsageLogs': totalUsageLogs,
        'totalWattsUsed': totalWattsUsed,
        'totalDurationSeconds': totalDurationSeconds,
        'totalKWh': totalKWh,
      };
    } catch (e) {
      print('Error calculating usage: $e');
      return {};
    }
  }

  // Calculate usage for a specific time period (e.g., this week)
  Future<Map<String, dynamic>> calculateWeeklyUsage() async {
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: 7));

    double totalWattsUsed = 0.0;
    int totalDurationSeconds = 0;

    try {
      QuerySnapshot homesSnapshot = await _firestore.collection('Homes').get();

      for (var homeDoc in homesSnapshot.docs) {
        QuerySnapshot equipmentSnapshot = await _firestore
            .collection('Homes')
            .doc(homeDoc.id)
            .collection('Equipments')
            .get();

        for (var equipmentDoc in equipmentSnapshot.docs) {
          QuerySnapshot usageLogsSnapshot = await _firestore
              .collection('Homes')
              .doc(homeDoc.id)
              .collection('Equipments')
              .doc(equipmentDoc.id)
              .collection('usageLogs')
              // .where('startTime', isGreaterThanOrEqualTo: weekStart)
              .get();

          for (var logDoc in usageLogsSnapshot.docs) {
            var data = logDoc.data() as Map<String, dynamic>;
            totalWattsUsed += (data['wattsUsed'] ?? 0.0) as double;
            totalDurationSeconds += (data['durationSeconds'] ?? 0) as int;
          }
        }
      }

      double weeklyKWh = (totalWattsUsed * totalDurationSeconds) / 3600000;

      return {
        'weeklyWattsUsed': totalWattsUsed,
        'weeklyDurationSeconds': totalDurationSeconds,
        'weeklyKWh': weeklyKWh,
      };
    } catch (e) {
      print('Error calculating weekly usage: $e');
      return {};
    }
  }
}
