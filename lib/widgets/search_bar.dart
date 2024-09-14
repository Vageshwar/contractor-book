import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isActive;
  final Function(String, bool) onSearch;

  const MySearchBar({
    Key? key,
    required this.controller,
    required this.isActive,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 32.0), // Increased top padding
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the search bar
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Subtle shadow
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 2), // Shadow positioning
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search Sites', // Placeholder text
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            border: InputBorder.none, // Remove default border
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          style: const TextStyle(fontSize: 16.0),
          onChanged: (value) {
            onSearch(value, isActive);
          },
        ),
      ),
    );
  }
}
