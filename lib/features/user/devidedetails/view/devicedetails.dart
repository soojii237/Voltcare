import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeviceDetailsPage extends StatefulWidget {
  final String deviceName;
  final String category;
  final bool isOn;

  const DeviceDetailsPage({
    Key? key,
    required this.deviceName,
    required this.category,
    this.isOn = false,
  }) : super(key: key);

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  bool currentState = false;

  // =======================
  // 🔹 ELECTRICITY RATE
  // =======================
  double ratePerKwh = 8.0; // ₹8 per kWh

  // Example usage values — later these will come from backend
  double todayUsage = 1.2;
  double weeklyUsage = 6.8;
  double monthlyUsage = 21.5;

  // Cost Calculations
  double get todayCost => todayUsage * ratePerKwh;
  double get weeklyCost => weeklyUsage * ratePerKwh;
  double get monthlyCost => monthlyUsage * ratePerKwh;

  @override
  void initState() {
    super.initState();
    currentState = widget.isOn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit device page
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteDevice,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:  EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // DEVICE ICON
            Icon(_getDeviceIcon(widget.category), size: 80.sp, color: Colors.blue),

             SizedBox(height: 10.h),

            Text(widget.category, style:  TextStyle(fontSize: 16.sp)),

             SizedBox(height: 20.h),

            // ON/OFF SWITCH
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Status: "),
                Switch(
                  value: currentState,
                  onChanged: (v) {
                    setState(() {
                      currentState = v;
                    });
                  },
                ),
                Text(
                  currentState ? "ON" : "OFF",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: currentState ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

             SizedBox(height: 30.h),

            // USAGE CIRCLE
            _usageCircle(),

             SizedBox(height: 20.h),

            // USAGE + COST CARD
            _usageInfoCard(),

             SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------
  // 🔵 CIRCULAR USAGE PROGRESS
  // --------------------------------------------
  Widget _usageCircle() {
    return SizedBox(
      height: 150.h,
      width: 150.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.55, // 55% used
            strokeWidth: 10.w,
            color: Colors.orange,
            backgroundColor: Colors.grey.shade300,
          ),
           Center(
            child: Text(
              "55%",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------
  // 🟢 USAGE + COST CARD
  // --------------------------------------------
  Widget _usageInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding:  EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Energy Consumption",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            const Divider(),
             SizedBox(height: 10.h),

            _usageRow("Rate (per kWh)", "₹$ratePerKwh"),

             SizedBox(height: 15.h),

            _usageRow("Today's Usage", "$todayUsage kWh"),
            _usageRow("Cost Today", "₹${todayCost.toStringAsFixed(2)}"),

            const SizedBox(height: 10),

            _usageRow("Weekly Usage", "$weeklyUsage kWh"),
            _usageRow("Weekly Cost", "₹${weeklyCost.toStringAsFixed(2)}"),

            const SizedBox(height: 10),

            _usageRow("Monthly Usage", "$monthlyUsage kWh"),
            _usageRow("Monthly Cost", "₹${monthlyCost.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------
  // REUSABLE ROW WIDGET
  // --------------------------------------------
  Widget _usageRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // --------------------------------------------
  // DELETE CONFIRMATION
  // --------------------------------------------
  void _deleteDevice() {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text("Delete Device?"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Device deleted"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------
  // DEVICE ICON SELECTOR
  // --------------------------------------------
  IconData _getDeviceIcon(String category) {
    switch (category) {
      case "Bulb":
        return Icons.lightbulb;
      case "Fan":
        return Icons.toys;
      case "AC":
        return Icons.ac_unit;
      case "TV":
        return Icons.tv;
      case "Fridge":
        return Icons.kitchen;
      case "Heater":
        return Icons.local_fire_department;
      default:
        return Icons.devices_other;
    }
  }
}
