import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/screens/site_details_page.dart';
import 'package:contractor_book/services/db_service.dart';

class SiteList extends StatelessWidget {
  final List<Sites> sites;
  final bool isActive;
  final Function(Sites) onTapSite;

  const SiteList({
    Key? key,
    required this.sites,
    required this.isActive,
    required this.onTapSite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        return FutureBuilder<List<Uint8List>>(
          future: DatabaseService().getSiteImages(site.siteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildSiteCard(context, site, null);
            } else {
              final images = snapshot.data!;
              return _buildSiteCard(context, site, images.first);
            }
          },
        );
      },
    );
  }

  Widget _buildSiteCard(BuildContext context, Sites site, Uint8List? image) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Softer rounded corners
      ),
      elevation: 2, // Minimal shadow for a clean look
      margin: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 16), // Reduce margin for more compact layout
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTapSite(site),
        child: Container(
          padding:
              const EdgeInsets.all(12.0), // Minimal padding inside the card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white, // Clean white background for minimalist design
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), // Very subtle shadow
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8), // Rounded corners for the image
                child: image != null
                    ? Image.memory(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 50,
                        color:
                            Colors.grey), // Placeholder icon with subtle color
              ),
              const SizedBox(width: 16), // Space between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      style: const TextStyle(
                        fontSize: 16, // Slightly smaller font
                        fontWeight:
                            FontWeight.w600, // Semi-bold for a clean look
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner: ${site.ownerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios, // Minimalist navigation icon
                color: Colors
                    .grey, // Lighter shade for subtle navigation indicator
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
