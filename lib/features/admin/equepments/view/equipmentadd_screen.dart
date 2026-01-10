// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltcare/features/admin/equepments/model/equipment_model.dart';
import 'package:voltcare/features/widgets/apptextfeild.dart';
import 'dart:io';

import 'package:voltcare/utils/helper/helper_image_picker.dart';
import 'package:voltcare/utils/helper/helper_pagenavigator.dart';

import '../../../../service/cloudinary_service.dart';
import '../../../widgets/appbutton.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  XFile? _selectedImage;
  bool isLoading = false;

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  var data = await pickImage(context: context, isCamera: false);
                  if (data['status'] == true && data['path'] != null) {
                    setState(() {
                      _selectedImage = XFile(data['path']);
                    });
                  } else {
                    setState(() {
                      _selectedImage = null;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  var data = await pickImage(context: context, isCamera: true);
                  if (data['status'] == true && data['path'] != null) {
                    setState(() {
                      _selectedImage = XFile(data['path']);
                    });
                  } else {
                    setState(() {
                      _selectedImage = null;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveEquipment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Simulate saving delay

      setState(() {
        isLoading = false;
      });
      var image = await CloudneryUploader().uploadFile(_selectedImage!);
      EquipmentsModel equipment = EquipmentsModel(
        name: _nameController.text,
        subtitle: _subtitleController.text,
        image: image,
        namefilter: [
          for (int i = 1; i <= _nameController.text.length; i++)
            _nameController.text.substring(0, i).toLowerCase(),
        ],
        status: 1,
        createdAt: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection('Equipments')
          .add(equipment.toJson()).then((value) {
            value.update({'id': value.id});
          },);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _nameController.clear();
      _subtitleController.clear();
      setState(() {
        _selectedImage = null;
      });
      Screen.close(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Equipment'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                const Text(
                  'Equipment Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 60,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Equipment Name Field
                AppTextField(
                  controller: _nameController,
                  fillColor: Colors.grey[100],
                
                  label: "Equipment Name",
                  hintText: 'e.g., Treadmill Pro 3000',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter equipment name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Subtitle/Secondary Name Field
                AppTextField(
                  controller: _subtitleController,
                  fillColor: Colors.grey[100],
                  
                  label: "Subtitle",
                  hintText: 'e.g., Model XR-500, Professional Grade',
                ),
                const SizedBox(height: 24),

                // Save Button
                AppButton(
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _saveEquipment,
                  text: "Add Equipment",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
