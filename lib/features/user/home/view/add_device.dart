import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController minCtrl = TextEditingController();
  final TextEditingController maxCtrl = TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    "Bulb",
    "Fan",
    "AC",
    "TV",
    "Fridge",
    "Heater",
    "Washing Machine",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Device"),
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding:  EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Name
            const Text(
              "Device Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 6.h),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: "Eg: Bedroom Bulb",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

             SizedBox(height: 20.h),

            // Category Dropdown
            const Text(
              "Device Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 6.h),
            Container(
              padding:  EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text("Select a category"),
                  isExpanded: true,
                  items: categories.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
            ),

             SizedBox(height: 20.h),

            // MIN ENERGY LIMIT
            const Text(
              "Min Energy Limit (kWh)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 6.h),
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Eg: 1",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

             SizedBox(height: 20.h),

            // MAX ENERGY LIMIT
            const Text(
              "Max Energy Limit (kWh)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 6.h),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Eg: 5",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

             SizedBox(height: 40.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDevice,
                style: ElevatedButton.styleFrom(
                  padding:  EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child:  Text(
                  "Save Device",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SAVE FUNCTION ----------------
  void _saveDevice() {
    if (nameCtrl.text.isEmpty ||
        selectedCategory == null ||
        minCtrl.text.isEmpty ||
        maxCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // You will replace this with Firestore/MongoDB
    print("Device Saved:");
    print("Name: ${nameCtrl.text}");
    print("Category: $selectedCategory");
    print("Min: ${minCtrl.text}");
    print("Max: ${maxCtrl.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Device Added Successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
