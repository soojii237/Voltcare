import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voltcare/features/admin/equepments/view/equipmentadd_screen.dart';
import 'package:voltcare/features/widgets/appbutton.dart';
import 'package:voltcare/features/widgets/apptext.dart';
import 'package:voltcare/utils/extension/upperfstring_ext.dart';
import 'package:voltcare/utils/helper/helper_pagenavigator.dart';

import '../model/equipment_model.dart';

class EquipmentListingPage extends StatefulWidget {
  const EquipmentListingPage({super.key});

  @override
  State<EquipmentListingPage> createState() => _EquipmentListingPageState();
}

class _EquipmentListingPageState extends State<EquipmentListingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Equipment Listing',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Equipment List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Equipments').where('status', isEqualTo: 1).
                  where('namefilter', arrayContains: _searchQuery.toLowerCase().isEmpty ? null : _searchQuery)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: AppText(
                      text: 'Error: ${snapshot.error}',
                      color: Colors.red,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          text: 'No equipment found',
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  );
                }

                // Convert documents to EquipmentsModel list
                List<EquipmentsModel> equipments = snapshot.data!.docs
                    .map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      return EquipmentsModel(
                        id: doc.id,
                        name: data['name'] ?? '',
                        subtitle: data['subtitle'] ?? '',
                        image: data['image'] ?? '',
                        status: data['status'] ?? 0,
                        namefilter: data['namefilter'].cast<String>(),
                      );
                    })
                    .toList();

                // Filter equipments based on search query
                if (_searchQuery.isNotEmpty) {
                  equipments = equipments.where((equipment) {
                    final nameMatch = equipment.name
                            ?.toLowerCase()
                            .contains(_searchQuery) ??
                        false;
                    final subtitleMatch = equipment.subtitle
                            ?.toLowerCase()
                            .contains(_searchQuery) ??
                        false;
                    
                    // Also search in namefilter array if it exists
                    final namefilterMatch = equipment.namefilter != null &&
                        equipment.namefilter!.any((filter) =>
                            filter.toLowerCase().contains(_searchQuery));

                    return nameMatch || subtitleMatch || namefilterMatch;
                  }).toList();
                }

                if (equipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          text: 'No results found for "$_searchQuery"',
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: equipments.length,
                  itemBuilder: (context, index) {
                    final equipment = equipments[index];
                    return EquipmentCard(equipment: equipment);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            text: 'Add New Equipment',
            onPressed: () {
              Screen.open(context, AddEquipmentScreen());
            },
          ),
        ),
      ),
    );
  }
}

class EquipmentCard extends StatelessWidget {
  final EquipmentsModel equipment;

  const EquipmentCard({Key? key, required this.equipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image with border radius 8
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                equipment.image ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Name and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: equipment.name ?? '',
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: equipment.subtitle?.upperFirst ?? '',
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  // Show status indicator if needed
                  if (equipment.status != null && equipment.status == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          text: 'Inactive',
                          size: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}