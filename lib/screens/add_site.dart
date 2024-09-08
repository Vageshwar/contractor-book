import 'package:contractor_book/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/models/site_images.dart';

class AddSitePage extends StatefulWidget {
  @override
  _AddSitePageState createState() => _AddSitePageState();
}

class _AddSitePageState extends State<AddSitePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _ownerIdController = TextEditingController();
  final _dateController = TextEditingController();

  bool _isLoading = false;
  int _activeStatus = 1; // Default active status as 1
  Uint8List? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  // Function to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path).readAsBytesSync();
      });
    }
  }

  // Show SnackBar for user feedback
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Submit form function
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new site object
        final newSite = Sites(
          siteId: 0, // Auto increment
          ownerName: _ownerIdController.text,
          date: DateTime.now().millisecondsSinceEpoch,
          active: _activeStatus,
          name: _nameController.text,
          location: _locationController.text,
        );

        // Insert site into the database
        await DatabaseService().insertSite(newSite);

        // If an image is selected, insert it into the database
        if (_selectedImage != null) {
          final newSiteImage = SiteImage(
            imageId: 0, // Auto increment
            image: _selectedImage!,
            siteId: newSite.siteId, // Site ID will be automatically assigned
          );
          await DatabaseService().insertImage(newSiteImage);
        }

        _showSnackBar("Site added successfully", Colors.green);

        // Navigate to the homepage or refresh the current page
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar("Error: $e", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Site"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Site Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the site name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _ownerIdController,
                        decoration:
                            const InputDecoration(labelText: 'Owner Name'),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the owner Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _selectedImage != null
                          ? Image.memory(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera),
                            label: const Text("Camera"),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Gallery"),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Button color
                            foregroundColor: Colors.white, // Text color
                          ),
                          onPressed: _submitForm,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
