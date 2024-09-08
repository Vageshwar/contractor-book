import 'package:contractor_book/models/contractor.dart'; // Import Contractor model
import 'package:contractor_book/screens/homepage.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _contractorName = '';
  String _address = '';
  String _contactNo = '';
  String _city = '';
  String _selectedTitle = 'Painting'; // Default selected title

  // List of titles for the dropdown
  final List<String> _titles = [
    'Painting',
    'POP',
    'Carpentering',
    'Construction',
    'Building',
    'Plumbing', // Added Plumbing
    'Electrical Work', // Added Electrical Work
    'Landscaping', // Added Landscaping,
    "Other",
  ];

  // Method to show the loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Submitting...'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to hide the loading dialog
  void _hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Only pop if there's something to pop
    }
  }

  // Method to insert contractor into ₹the database
  Future<void> _insertContractor() async {
    Contractor contractor = Contractor(
      contractorId: 0,
      name: _contractorName.toString(),
      address: _address.toString(),
      phone: _contactNo.toString(),
      city: _city.toString(),
      title: _selectedTitle.toString(), // Set title from the dropdown
    );
    await DatabaseService().insertContractor(contractor);
  }

  // Method to validate and save the form
  Future<void> _submitForm() async {
    print("Adding");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show the loading dialog
      _showLoadingDialog(context);

      try {
        // Insert contractor into database
        await _insertContractor();

        // After inserting, close the loading dialog
        _hideLoadingDialog(context);
        await Future.delayed(Duration(milliseconds: 100));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contractor added successfully!')),
        );
        // Hide the loading dialog
        _hideLoadingDialog(context);
        // Navigate to HomePage after successful creation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        // Show error message
        // Hide the loading dialog
        _hideLoadingDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contractor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
            top: 60.0, left: 16.0, right: 16.0), // Added top padding
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Contractor's Book Logo
              Image.asset(
                'assets/logo.png', // Ensure this is your logo path
                height: 100,
              ),
              const SizedBox(height: 20),

              // Welcome Text
              const Text(
                'Welcome to Contractor\'s Book,',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Instruction Text
              const Text(
                'Enter your Basic Details to get started.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Contractor Name Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Contractor Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        } else if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _contractorName = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _address = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // City Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _city = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Contact No Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Contact No',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                            10), // Limit to 10 digits
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        } else if (value.length != 10) {
                          return 'Contact number must be 10 digits';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _contactNo = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Title Dropdown Field
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedTitle,
                      items: _titles.map((title) {
                        return DropdownMenuItem(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTitle = newValue!;
                        });
                      },
                      onSaved: (value) {
                        _selectedTitle = value!;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity, // Make button full width
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Colors.black, // Changed color to white
                          foregroundColor: Colors.white, // Text color
                        ),
                        child: const Text('Submit',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
