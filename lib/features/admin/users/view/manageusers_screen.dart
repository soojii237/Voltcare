import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:voltcare/utils/constants/app_colors.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  String selectedFilter = "active"; // default filter

  Stream<QuerySnapshot> getStudents() {
    final collection = FirebaseFirestore.instance.collection("Users");

    if (selectedFilter == "all") {
      return collection.where("role", isEqualTo: "user").snapshots();
    } else if (selectedFilter == "active") {
      return collection
          .where("role", isEqualTo: "user")
          .where("status", isEqualTo: 1)
          .snapshots();
    } else if (selectedFilter == "blocked") {
      return collection
          .where("role", isEqualTo: "user")
          .where("status", isEqualTo: 0)
          .snapshots();
    } else if (selectedFilter == "deleted") {
      return collection
          .where("role", isEqualTo: "user")
          .where("status", isEqualTo: -1)
          .snapshots();
    }

    return collection.snapshots();
  }

  // ---------- BLOCK/UNBLOCK STUDENT METHOD ----------
  Future<void> toggleBlockStudent(String uid, int currentStatus) async {
    try {
      int newStatus = currentStatus == 1
          ? 0
          : 1; // Toggle between active (1) and blocked (0)

      await FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "status": newStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 0 ? "Student blocked" : "Student unblocked",
            ),
            backgroundColor: newStatus == 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------- DELETE STUDENT METHOD ----------
  Future<void> deleteStudent(String uid) async {
    try {
      await FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "status": -1,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student deleted"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------- UNDELETE STUDENT METHOD ----------
  Future<void> undeleteStudent(String uid) async {
    try {
      await FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "status": 1,
      }); // Restore to active status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student restored"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // ---------- FILTER BUTTONS ----------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                filterButton("all", "All"),
                filterButton("active", "Active"),
                filterButton("blocked", "Blocked"),
                filterButton("deleted", "Deleted"),
              ],
            ),
          ),

          const Divider(height: 20),

          // ---------- STUDENT LIST ----------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                final students = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student =
                        students[index].data() as Map<String, dynamic>;
                    int status = student["status"] ?? 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          child: Text(student["name"][0].toUpperCase()),
                        ),
                        title: Text(student["name"]),
                        subtitle: Text(student["email"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Block/Unblock Button (only show if not deleted)
                            if (status != -1)
                              IconButton(
                                icon: Icon(
                                  status == 1
                                      ? Icons.block
                                      : Icons.check_circle,
                                  color: status == 1
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                onPressed: () {
                                  toggleBlockStudent(student["uid"], status);
                                },
                                tooltip: status == 1 ? "Block" : "Unblock",
                              ),

                            // Delete/Undelete Button
                            if (status == -1)
                              // Undelete button for deleted students
                              IconButton(
                                icon: const Icon(
                                  Icons.restore,
                                  color: AppColors.iconBlue,
                                ),
                                onPressed: () {
                                  undeleteStudent(student["uid"]);
                                },
                                tooltip: "Restore",
                              )
                            else
                              // Delete button for active/blocked students
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  deleteStudent(student["uid"]);
                                },
                                tooltip: "Delete",
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------- FILTER BUTTON WIDGET -----------
  Widget filterButton(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == value,
        selectedColor: Colors.green,
        onSelected: (_) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),
    );
  }
}
