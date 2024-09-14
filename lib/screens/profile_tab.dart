import 'package:flutter/material.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:contractor_book/models/contractor.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final DatabaseService dbService = DatabaseService();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _titleController;

  bool isEditing = false; // Toggle for edit mode
  Contractor? contractor; // Holds the contractor data, initially null

  @override
  void initState() {
    super.initState();
    _fetchContractorData();
  }

  Future<void> _fetchContractorData() async {
    final fetchedContractor = await dbService.getCurrentUser();
    setState(() {
      contractor = fetchedContractor;
      _nameController = TextEditingController(text: contractor!.name);
      _addressController = TextEditingController(text: contractor!.address);
      _cityController = TextEditingController(text: contractor!.city);
      _phoneController = TextEditingController(text: contractor!.phone);
      _titleController = TextEditingController(text: contractor!.title);
    });
  }

  Future<void> _updateContractor() async {
    Contractor updatedContractor = Contractor(
      contractorId: contractor!.contractorId,
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      phone: _phoneController.text,
      title: _titleController.text,
    );

    await dbService.updateContractor(updatedContractor);

    setState(() {
      contractor = updatedContractor;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _cancelEdits() {
    setState(() {
      // Reset the controllers to the original contractor data
      _nameController.text = contractor!.name;
      _addressController.text = contractor!.address;
      _cityController.text = contractor!.city;
      _phoneController.text = contractor!.phone;
      _titleController.text = contractor!.title;

      isEditing = false; // Exit the edit mode
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if contractor is null, show loader if data is not yet loaded
    if (contractor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Main Profile UI when contractor data is available
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileField(
                'Name', Icons.person, _nameController, isEditing),
            _buildProfileField(
                'Address', Icons.home, _addressController, isEditing),
            _buildProfileField(
                'City', Icons.location_city, _cityController, isEditing),
            _buildProfileField(
                'Phone', Icons.phone, _phoneController, isEditing),
            _buildProfileField(
                'Title', Icons.work, _titleController, isEditing),
            const SizedBox(height: 20),
            if (isEditing) // Show Save and Cancel buttons only in edit mode
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _updateContractor,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _cancelEdits,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: isEditing
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              child: const Icon(Icons.edit),
              backgroundColor: Colors.blueAccent,
              tooltip: 'Edit Profile',
            ),
    );
  }

  Widget _buildProfileField(String label, IconData icon,
      TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          isEditable
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(icon),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Text(
                        controller.text,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
